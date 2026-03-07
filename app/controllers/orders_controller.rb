class OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def show
    @order = current_user.orders.find(params[:id])
  end

  def new
    if @cart.cart_items.empty?
      redirect_to cart_path, alert: t("cart_empty_error")
      return
    end

    @order = Order.new
    # Pre-fill with user information
    @order.name = current_user.name
    @order.email = current_user.email
  end

  def create
    @order = current_user.orders.new(order_params)
    @order.status = "pending"
    @order.estimated_delivery_date = 5.days.from_now


    # Calculate total from cart
    total = 0

    @cart.cart_items.each do |cart_item|
      total += cart_item.subtotal
    end

    @order.total_price = total

    if @order.save
      # Transfer cart items to order items
      @cart.cart_items.each do |cart_item|
        @order.order_items.create(
          variant: cart_item.variant,
          quantity: cart_item.quantity,
          price: cart_item.variant.price || cart_item.product.price
        )

        # Reduce variant quantity
        variant = cart_item.variant
        variant.quantity -= cart_item.quantity
        variant.save!
      end

      # Clear the cart
      @cart.cart_items.destroy_all

      redirect_to order_path(@order), notice: t("order_placed_success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def order_params
    params.require(:order).permit(:name, :email, :address, :phone)
  end
end
