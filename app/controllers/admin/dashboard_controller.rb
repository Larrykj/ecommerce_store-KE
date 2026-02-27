# frozen_string_literal: true

class Admin::DashboardController < Admin::BaseController
  def index
    @total_revenue = Order.sum(:total_price)
    @total_orders = Order.count
    @total_users = User.kept.count
    @total_products = Product.kept.count
    @recent_orders = Order.order(created_at: :desc).limit(10).includes(:user)
    @low_stock_variants = Variant.where("quantity <= 5").includes(:product).order(:quantity).limit(10)
    @top_products = Product.kept
                           .joins(:variants => :order_items)
                           .group("products.id")
                           .select("products.*, SUM(order_items.quantity) as total_sold")
                           .order("total_sold DESC")
                           .limit(5)

    # Monthly revenue for chart
    @monthly_revenue = Order.where("created_at >= ?", 6.months.ago)
                            .group_by { |o| o.created_at.strftime("%b %Y") }
                            .transform_values { |orders| orders.sum(&:total_price) }

    # Order status breakdown
    @order_status_counts = Order.group(:status).count

    # Top categories by revenue
    @top_categories = Category.joins(products: { variants: { order_items: :order } })
                              .group("categories.id", "categories.name")
                              .select("categories.name, SUM(order_items.price * order_items.quantity) as total_revenue")
                              .order("total_revenue DESC")
                              .limit(5)

    # Unread messages count
    @unread_messages = ContactMessage.unread.count rescue 0

    # Paid orders revenue
    @paid_revenue = Order.where(payment_status: "paid").sum(:total_price)
  end
end
