# frozen_string_literal: true

class BackInStockNotificationJob < ApplicationJob
  queue_as :default

  def perform(product_id)
    product = Product.find_by(id: product_id)
    return unless product&.total_quantity.to_i > 0

    notifications = StockNotification.pending.for_product(product)
    notifications.each do |notification|
      StockNotificationMailer.back_in_stock(notification).deliver_later
      notification.update!(notified: true)
    end

    Rails.logger.info "Sent back-in-stock notifications to #{notifications.count} subscribers for #{product.name}"
  end
end
