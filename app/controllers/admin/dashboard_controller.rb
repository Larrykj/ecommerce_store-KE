# frozen_string_literal: true

class Admin::DashboardController < Admin::BaseController
  def index
    # Core counts — lightweight queries with kept scope
    @total_revenue = Order.where.not(payment_status: "unpaid").sum(:total_price)
    @total_orders = Order.count
    @total_users = User.kept.count
    @total_products = Product.kept.count

    # Recent orders — limit and eager load
    @recent_orders = Order.order(created_at: :desc).limit(10).includes(:user)

    # Low stock — indexed query
    @low_stock_variants = Variant.where("quantity <= 5").includes(:product).order(:quantity).limit(10)

    # Top products — single SQL query
    @top_products = Product.kept
                           .joins(variants: :order_items)
                           .group(:id)
                           .select(Arel.sql("products.*, SUM(order_items.quantity) as total_sold"))
                           .order(Arel.sql("total_sold DESC"))
                           .limit(5)

    # Monthly revenue — use SQL GROUP BY instead of Ruby grouping
    @monthly_revenue = Order.where("created_at >= ?", 6.months.ago)
                            .group(Arel.sql("DATE_TRUNC('month', created_at)"))
                            .order(Arel.sql("DATE_TRUNC('month', created_at)"))
                            .pluck(Arel.sql("DATE_TRUNC('month', created_at)"), Arel.sql("SUM(total_price)"))
                            .to_h { |month, total| [ month.to_date.strftime("%b %Y"), total.to_f ] }

    # Daily revenue last 14 days
    @daily_revenue = Order.where("created_at >= ?", 14.days.ago)
                          .group(Arel.sql("DATE(created_at)"))
                          .order(Arel.sql("DATE(created_at)"))
                          .pluck(Arel.sql("DATE(created_at)"), Arel.sql("SUM(total_price)"))
                          .to_h { |date, total| [ date.to_date.strftime("%b %d"), total.to_f ] }

    # Order status breakdown — single query
    @order_status_counts = Order.group(:status).count

    # Top categories — single SQL query
    @top_categories = Category.joins(products: { variants: { order_items: :order } })
                              .group(:id, :name)
                              .select(Arel.sql("categories.name, SUM(order_items.price * order_items.quantity) as total_revenue"))
                              .order(Arel.sql("total_revenue DESC"))
                              .limit(5)

    # Unread messages
    @unread_messages = ContactMessage.unread.count

    # Paid orders revenue
    @paid_revenue = Order.where(payment_status: "paid").sum(:total_price)
  end
end
