# frozen_string_literal: true

class CheckoutsController < ApplicationController
  before_action :authenticate_user!

  # POST /checkout — Create order + Stripe session
  def create
    if @cart.cart_items.empty?
      redirect_to cart_path, alert: t("cart_empty_error")
      return
    end

    # Build the order
    @order = current_user.orders.new(order_params)
    @order.status = "pending"
    @order.payment_status = "unpaid"
    @order.estimated_delivery_date = 5.days.from_now

    # Calculate total from cart with discount, shipping, tax
    @order.promo_code = @cart.promo_code
    @order.discount_amount = @cart.discount_amount
    @order.shipping_method = @cart.shipping_method
    @order.shipping_cost = @cart.shipping_cost
    @order.tax_amount = @cart.tax_amount
    @order.tax_rate = Cart::TAX_RATE
    @order.total_price = @cart.total_price

    if @order.save
      # Transfer cart items to order items
      @cart.cart_items.each do |cart_item|
        @order.order_items.create!(
          variant: cart_item.variant,
          quantity: cart_item.quantity,
          price: cart_item.variant.price || 0
        )
      end

      # Create Stripe Checkout Session
      begin
        session_params = {
          payment_method_types: [ "card" ],
          mode: "payment",
          customer_email: current_user.email,
          line_items: build_line_items,
          metadata: { order_id: @order.id },
          success_url: checkout_success_url(order_id: @order.id, session_id: "{CHECKOUT_SESSION_ID}"),
          cancel_url: checkout_cancel_url(order_id: @order.id)
        }

        # Apply discount to Stripe via ephemeral coupon if needed
        if @cart.discount_amount > 0
          coupon_params = { duration: "once", name: @cart.promo_code.code }
          if @cart.promo_code.discount_type == "percentage"
            coupon_params[:percent_off] = @cart.promo_code.discount_value
          else
            coupon_params[:amount_off] = (@cart.discount_amount * 100).to_i
            coupon_params[:currency] = "kes"
          end
          stripe_coupon = Stripe::Coupon.create(coupon_params)
          session_params[:discounts] = [ { coupon: stripe_coupon.id } ]
        end

        session = Stripe::Checkout::Session.create(session_params)

        @order.update!(stripe_checkout_session_id: session.id)

        # Create a pending transaction record
        @order.transactions.create!(
          stripe_checkout_session_id: session.id,
          amount: @order.total_price,
          currency: "kes",
          status: "pending"
        )

        redirect_to session.url, allow_other_host: true, status: :see_other
      rescue Stripe::StripeError => e
        @order.destroy
        redirect_to new_order_path, alert: "Payment error: #{e.message}"
      end
    else
      render "orders/new", status: :unprocessable_entity
    end
  end

  # GET /checkout/success
  def success
    @order = current_user.orders.find(params[:order_id])

    if @order.payment_pending?
      # Verify the session with Stripe
      begin
        session = Stripe::Checkout::Session.retrieve(@order.stripe_checkout_session_id)

        if session.payment_status == "paid"
          @order.update!(payment_status: "paid", status: "processing")

          # Update transaction
          transaction = @order.transactions.find_by(stripe_checkout_session_id: session.id)
          transaction&.update!(
            stripe_payment_intent_id: session.payment_intent,
            status: "succeeded",
            payment_method: "card"
          )

          # Deduct inventory
          @order.order_items.each do |item|
            variant = item.variant
            variant.update!(quantity: [ variant.quantity - item.quantity, 0 ].max) if variant
          end

          # Increment promo code usage if applicable
          @order.promo_code&.increment_usage!

          # Clear the cart and its promo code
          @cart.update!(promo_code: nil)
          @cart.cart_items.destroy_all

          # Send confirmation email
          OrderMailer.with(order: @order).confirmation.deliver_later
        end
      rescue Stripe::StripeError => e
        Rails.logger.error "Stripe verification error: #{e.message}"
      end
    end

    redirect_to order_path(@order), notice: t("order_placed_success", default: "Order placed successfully! Payment confirmed.")
  end

  # GET /checkout/cancel
  def cancel
    @order = current_user.orders.find(params[:order_id])
    @order.update!(status: "cancelled", payment_status: "unpaid")
    @order.order_items.destroy_all

    redirect_to cart_path, alert: t("payment_cancelled", default: "Payment was cancelled. Your cart items are still saved.")
  end

  private

  def order_params
    params.require(:order).permit(:name, :email, :address, :phone)
  end

  def build_line_items
    items = @cart.cart_items.includes(variant: :product).map do |cart_item|
      product = cart_item.variant.product
      {
        price_data: {
          currency: "kes",
          product_data: {
            name: "#{product.name} — #{cart_item.variant.name}",
            description: product.description&.truncate(200)
          },
          unit_amount: (cart_item.variant.price * 100).to_i # Stripe expects cents
        },
        quantity: cart_item.quantity
      }
    end

    if @cart.shipping_cost > 0
      items << {
        price_data: {
          currency: "kes",
          product_data: { name: "Shipping — #{@cart.shipping_method.name}" },
          unit_amount: (@cart.shipping_cost * 100).to_i
        },
        quantity: 1
      }
    end

    if @cart.tax_amount > 0
      items << {
        price_data: {
          currency: "kes",
          product_data: { name: "Tax (16% VAT)" },
          unit_amount: (@cart.tax_amount * 100).to_i
        },
        quantity: 1
      }
    end

    items
  end
end
