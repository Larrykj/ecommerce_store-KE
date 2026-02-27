# frozen_string_literal: true

class ReturnRequestsController < ApplicationController
  before_action :authenticate_user!

  def new
    @order = current_user.orders.find(params[:order_id])
    @return_request = @order.build_return_request(user: current_user)
  end

  def create
    @order = current_user.orders.find(params[:order_id])
    @return_request = @order.build_return_request(return_request_params)
    @return_request.user = current_user

    if @return_request.save
      redirect_to order_path(@order), notice: "Return request submitted. We'll review it within 2 business days."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @return_requests = current_user.return_requests.recent.includes(:order)
  end

  private

  def return_request_params
    params.require(:return_request).permit(:reason, :description)
  end
end
