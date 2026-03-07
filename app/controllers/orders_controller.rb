# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [ :show, :cancel, :update_status ]
  before_action :authorize_admin_for_status_update!, only: [ :update_status ]

  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def show
  end

  def new
    if @cart.cart_items.empty?
      redirect_to cart_path, alert: t("cart_empty_error")
      return
    end

    @order = Order.new
    @order.name = current_user.name
    @order.email = current_user.email
    @payment_methods = [ "sandbox_test_card", "cash_on_delivery", "manual_confirmation" ]
  end

  def create
    @order = current_user.orders.new(order_params)
    @order.status = "pending"
    @order.estimated_delivery_date = 5.days.from_now
    @order.payment_method = params[:order][:payment_method]
    @order.payment_status = "pending"

    # Wrap entire checkout in transaction with locking
    begin
      Order.transaction do
        # Validate stock before creating order
        @cart.cart_items.each do |cart_item|
          variant = Variant.lock.find(cart_item.variant_id)
          if variant.quantity < cart_item.quantity
            raise ActiveRecord::Rollback, t("insufficient_stock", default: "Insufficient stock for #{variant.name}")
          end
        end

        # Save the order
        unless @order.save
          raise ActiveRecord::Rollback, @order.errors.full_messages.join(", ")
        end

        # Calculate total and create order items with locked variants
        total = 0
        @cart.cart_items.each do |cart_item|
          variant = Variant.lock.find(cart_item.variant_id)

          # Double-check stock with lock
          if variant.quantity < cart_item.quantity
            raise ActiveRecord::Rollback, t("insufficient_stock", default: "Insufficient stock")
          end

          # Create order item
          @order.order_items.create!(
            variant: variant,
            quantity: cart_item.quantity,
            price: variant.price || cart_item.product.price
          )

          total += cart_item.subtotal

          # Reduce variant quantity atomically
          variant.update!(quantity: variant.quantity - cart_item.quantity)
        end

        # Set order total
        @order.update!(total_price: total)

        # Process payment
        process_payment(@order)

        # Clear the cart
        @cart.cart_items.destroy_all

        # Send confirmation email
        prepare_order_email(@order)
      end

      redirect_to order_path(@order), notice: t("order_placed_success")
    rescue ActiveRecord::Rollback => e
      @order.errors.add(:base, e.message)
      render :new, status: :unprocessable_entity
    rescue StandardError => e
      Rails.logger.error("Order creation error: #{e.message}")
      @order.errors.add(:base, t("order_creation_failed", default: "Failed to create order. Please try again."))
      render :new, status: :unprocessable_entity
    end
  end

  def cancel
    if %w[pending paid processing].include?(@order.status)
      Order.transaction do
        @order.order_items.each do |item|
          variant = Variant.lock.find(item.variant_id)
          variant.update!(quantity: variant.quantity + item.quantity)
        end
        @order.update!(status: "cancelled")
      end
      redirect_to @order, notice: t("order_cancelled_success", default: "Order has been cancelled successfully.")
    else
      redirect_to @order, alert: t("order_cannot_cancel", default: "Order cannot be cancelled at this stage.")
    end
  end

  def update_status
    new_status = params[:status]
    if OrderService.valid_status_transition?(@order.status, new_status)
      if @order.update(status: new_status)
        OrderMailer.with(order: @order).status_updated.deliver_later if new_status == "shipped"
        redirect_to @order, notice: t("order_status_updated", default: "Order status updated successfully.")
      else
        redirect_to @order, alert: t("status_update_failed", default: "Failed to update order status.")
      end
    else
      redirect_to @order, alert: t("invalid_status_transition", default: "Invalid status transition.")
    end
  end

  private

  def set_order
    @order = current_user.orders.find(params[:id])
  end

  def authorize_admin_for_status_update!
    unless current_user.admin?
      redirect_to root_path, alert: t("admin_access_denied", default: "You do not have permission to perform this action.")
    end
  end

  def order_params
    params.require(:order).permit(:name, :email, :address_id, :phone, :notes)
  end

  def process_payment(order)
    case order.payment_method
    when "sandbox_test_card"
      order.update!(payment_status: "completed")
    when "cash_on_delivery"
      order.update!(payment_status: "pending")
    when "manual_confirmation"
      order.update!(payment_status: "pending")
    end
  end

  def prepare_order_email(order)
    OrderMailer.with(order: order).confirmation.deliver_later
  end
end
