# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @recent_orders = current_user.orders.order(created_at: :desc).limit(5)
    @addresses = current_user.addresses.ordered
    @wishlist_count = current_user.wishlist_items.count
    @reviews_count = current_user.reviews.count
    @total_orders = current_user.orders.count
    @total_spent = current_user.orders.where(payment_status: "paid").sum(:total_price)
  end
end
