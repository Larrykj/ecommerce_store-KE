# frozen_string_literal: true

class LowInventoryAlertJob < ApplicationJob
  queue_as :default

  LOW_STOCK_THRESHOLD = 5

  def perform
    low_stock_variants = Variant.where("quantity <= ?", LOW_STOCK_THRESHOLD)
                                .where("quantity > 0")
                                .includes(:product)

    out_of_stock_variants = Variant.where(quantity: 0).includes(:product)

    if low_stock_variants.any? || out_of_stock_variants.any?
      # Notify admin users
      User.where(admin: true).each do |admin|
        AdminMailer.low_inventory_alert(admin, low_stock_variants, out_of_stock_variants).deliver_later
      end

      Rails.logger.info "Low inventory alert sent: #{low_stock_variants.count} low stock, #{out_of_stock_variants.count} out of stock"
    end
  end
end
