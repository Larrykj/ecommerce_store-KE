# frozen_string_literal: true

class Admin::OrdersController < Admin::BaseController
  before_action :set_order, only: [ :show, :update ]

  def index
    @orders = Order.order(created_at: :desc).includes(:user)
    @orders = @orders.where(status: params[:status]) if params[:status].present?
    @pagy, @orders = pagy(@orders, items: 25)
  end

  def show
    @order_items = @order.order_items.includes(variant: :product)
  end

  def update
    previous_status = @order.status
    new_status = order_params[:status]

    # Validate status transitions to prevent invalid state changes
    if new_status.present? && !OrderService.valid_status_transition?(previous_status, new_status)
      redirect_to admin_order_path(@order), alert: "Invalid status transition from '#{previous_status}' to '#{new_status}'."
      return
    end

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
    params.require(:order).permit(:status, :tracking_number, :shipping_carrier)
  end
end
