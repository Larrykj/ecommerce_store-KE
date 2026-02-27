# frozen_string_literal: true

class Admin::OrdersController < Admin::BaseController
  before_action :set_order, only: [ :show, :update ]

  def index
    @orders = Order.order(created_at: :desc).includes(:user)
    @orders = @orders.where(status: params[:status]) if params[:status].present?
  end

  def show
    @order_items = @order.order_items.includes(variant: :product)
  end

  def update
    previous_status = @order.status
    if @order.update(order_params)
      if previous_status != "shipped" && @order.status == "shipped"
        OrderMailer.with(order: @order).shipped.deliver_later
      end
      redirect_to admin_order_path(@order), notice: "Order updated successfully."
    else
      redirect_to admin_order_path(@order), alert: "Failed to update order."
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:status)
  end
end
