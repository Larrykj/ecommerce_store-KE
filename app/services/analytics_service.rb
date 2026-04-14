class AnalyticsService
  def self.stats(range = 30.days)
    {
      revenue: Order.where(status: :completed).where("created_at >= ?", range).sum(:total),
      orders: Order.where(status: :completed).where("created_at >= ?", range).count,
      customers: User.where("created_at >= ?", range).count,
      average_order_value: Order.where(status: :completed).where("created_at >= ?", range).average(:total) || 0,
      top_products: top_products(range),
      sales_by_day: sales_by_day(range),
      traffic_sources: traffic_sources(range)
    }
  end

  def self.top_products(range, limit = 10)
    Product.joins(:order_items)
           .where(order_items: { order: Order.where(status: :completed, created_at: range) })
           .group("products.id")
           .select("products.id, products.name, SUM(order_items.quantity) as total_sold")
           .order("total_sold DESC")
           .limit(limit)
  end

  def self.sales_by_day(range)
    Order.where(status: :completed, created_at: range)
         .group("DATE(created_at)")
         .order("DATE(created_at)")
         .sum(:total)
  end

  def self.traffic_sources(range)
    ProductView.where(created_at: range)
               .group(:referrer)
               .count
               .transform_keys { |k| k.presence || "Direct" }
  end
end
