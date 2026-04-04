# frozen_string_literal: true

class CheckoutsController < ApplicationController
  before_action :authenticate_user!

  STRIPE_CURRENCY = "kes".freeze

  # POST /checkout - Create order + Stripe session
  # This is the Stripe-integrated checkout flow.
  # See OrdersController#create for the legacy/simplified checkout.
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
    @order.gift_card = @cart.gift_card
    @order.gift_card_amount = @cart.gift_card_amount
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

      payment_method = params[:payment_method] || "stripe"

      if @order.total_price <= 0
        # Gift card covers entire cost — bypass payment gateways
        complete_order_locally(@order, "gift_card", "succeeded",
          t("order_placed_gift_card", default: "Order placed successfully! Paid via Gift Card."))
      elsif payment_method == "stripe"
        process_stripe_payment
      elsif payment_method == "cod"
        complete_order_locally(@order, "cod", "pending",
          t("order_placed_cod", default: "Order placed successfully! You will pay on delivery."))
      elsif payment_method == "mpesa"
        complete_order_locally(@order, "mpesa", "succeeded",
          t("order_placed_mpesa", default: "Order placed successfully! M-Pesa payment confirmed."))
      elsif payment_method == "bank_transfer"
        complete_order_locally(@order, "bank_transfer", "pending",
          t("order_placed_bank_transfer", default: "Order placed successfully! Please transfer the amount to our bank account."))
      else
        redirect_to new_order_path, alert: "Invalid payment method selected."
      end
    else
      render "orders/new", status: :unprocessable_entity
    end
  end

  # GET /checkout/success
  def success
    @order = current_user.orders.find(params[:order_id])

    @order.with_lock do
      if @order.payment_status == "unpaid" || @order.status == "pending"
        begin
          session = Stripe::Checkout::Session.retrieve(@order.stripe_checkout_session_id)

          if session.payment_status == "paid"
            @order.update!(payment_status: "paid", status: "processing")

            transaction = @order.transactions.find_by(stripe_checkout_session_id: session.id)
            transaction&.update!(
              stripe_payment_intent_id: session.payment_intent,
              status: "succeeded",
              payment_method: "card"
            )

            deduct_inventory
            @order.gift_card&.apply!(@order.gift_card_amount)
            @order.promo_code&.increment_usage!
            clear_cart
            OrderMailer.with(order: @order).confirmation.deliver_later
          end
        rescue Stripe::StripeError => e
          Rails.logger.error "Stripe verification error: #{e.message}"
        end
      end
    end

    redirect_to order_path(@order), notice: t("order_placed_success", default: "Order placed successfully! Payment confirmed.")
  end

  # GET /checkout/cancel
  def cancel
    @order = current_user.orders.find(params[:order_id])
    Order.transaction do
      # Restore inventory for cancelled order
      @order.order_items.each do |item|
        variant = Variant.lock.find(item.variant_id)
        variant.update!(quantity: variant.quantity + item.quantity)
      end
      @order.update!(status: "cancelled", payment_status: "unpaid")
      @order.order_items.destroy_all
    end

    redirect_to cart_path, alert: t("payment_cancelled", default: "Payment was cancelled. Your cart items are still saved.")
  end

  private

  def order_params
    params.require(:order).permit(:name, :email, :address, :phone)
  end

  # Shared method for non-Stripe payment methods (COD, M-Pesa, Bank Transfer, Gift Card)
  def complete_order_locally(order, payment_method, txn_status, notice_msg)
    order_status = txn_status == "succeeded" ? "processing" : "pending"
    @order.update!(payment_status: txn_status, status: order_status)
    @order.transactions.create!(payment_method: payment_method, amount: @order.total_price, currency: STRIPE_CURRENCY, status: txn_status)
    deduct_inventory
    @order.gift_card&.apply!(@order.gift_card_amount)
    @order.promo_code&.increment_usage!
    clear_cart
    OrderMailer.with(order: @order).confirmation.deliver_later
    redirect_to order_path(@order), notice: notice_msg
  end

  def build_line_items
    items = @cart.cart_items.includes(variant: :product).map do |cart_item|
      product = cart_item.variant.product
      {
        price_data: {
          currency: STRIPE_CURRENCY,
          product_data: {
            name: "#{product.name} - #{cart_item.variant.name}",
            description: product.description&.truncate(200)
          },
          unit_amount: (cart_item.variant.price * 100).to_i
        },
        quantity: cart_item.quantity
      }
    end

    if @cart.shipping_cost > 0
      items << {
        price_data: {
          currency: STRIPE_CURRENCY,
          product_data: { name: "Shipping - #{@cart.shipping_method.name}" },
          unit_amount: (@cart.shipping_cost * 100).to_i
        },
        quantity: 1
      }
    end

    if @cart.tax_amount > 0
      items << {
        price_data: {
          currency: STRIPE_CURRENCY,
          product_data: { name: "Tax (16% VAT)" },
          unit_amount: (@cart.tax_amount * 100).to_i
        },
        quantity: 1
      }
    end

    items
  end

  def process_stripe_payment
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

      if @cart.discount_amount > 0
        coupon_params = { duration: "once", name: @cart.promo_code.code }
        if @cart.promo_code.discount_type == "percentage"
          coupon_params[:percent_off] = @cart.promo_code.discount_value
        else
          coupon_params[:amount_off] = (@cart.discount_amount * 100).to_i
          coupon_params[:currency] = STRIPE_CURRENCY
        end
        stripe_coupon = Stripe::Coupon.create(coupon_params)
        session_params[:discounts] = [ { coupon: stripe_coupon.id } ]
      end

      session = Stripe::Checkout::Session.create(session_params)

      @order.update!(stripe_checkout_session_id: session.id)

      @order.transactions.create!(
        stripe_checkout_session_id: session.id,
        amount: @order.total_price,
        currency: STRIPE_CURRENCY,
        status: "pending"
      )

      redirect_to session.url, allow_other_host: true, status: :see_other
    rescue Stripe::StripeError => e
      @order.destroy
      redirect_to new_order_path, alert: "Payment error: #{e.message}"
    end
  end

  def clear_cart
    @cart.update!(promo_code: nil)
    @cart.cart_items.destroy_all
  end

  def deduct_inventory
    @order.order_items.each do |item|
      variant = item.variant
      variant.with_lock do
        if variant.quantity < item.quantity
          raise StandardError, "Not enough stock for variant #{variant.id}"
        end
        variant.update!(quantity: variant.quantity - item.quantity)
      end
    end
  end
end
