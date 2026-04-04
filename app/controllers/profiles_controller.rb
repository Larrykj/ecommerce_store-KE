# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @recent_orders = current_user.orders.includes(:order_items).order(created_at: :desc).limit(5)
    @addresses = current_user.addresses.ordered
    
    # Optimize count queries - use SQL aggregation instead of Ruby counting
    profile_stats = current_user.orders.reorder(nil).group(nil).select(
      "COUNT(*) as total_orders",
      "SUM(CASE WHEN payment_status = 'paid' THEN total_price ELSE 0 END) as total_spent"
    ).take
    
    @wishlist_count = current_user.wishlist_items.count
    @reviews_count = current_user.reviews.count
    @total_orders = profile_stats&.total_orders || 0
    @total_spent = profile_stats&.total_spent || 0
  end
end
