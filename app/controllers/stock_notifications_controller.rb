# frozen_string_literal: true

class StockNotificationsController < ApplicationController
  def create
    @notification = StockNotification.new(
      product_id: params[:product_id],
      email: params[:email] || current_user&.email,
      user: current_user
    )

    if @notification.save
      redirect_back fallback_location: product_path(params[:product_id]), notice: "We'll notify you when this product is back in stock!"
    else
      redirect_back fallback_location: product_path(params[:product_id]), alert: @notification.errors.full_messages.first
    end
  end
end
