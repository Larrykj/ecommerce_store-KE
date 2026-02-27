# frozen_string_literal: true

class AbandonedCartReminderJob < ApplicationJob
  queue_as :default

  def perform
    # Find carts that haven't been updated in 24+ hours and have items
    Cart.joins(:cart_items)
        .where("carts.updated_at < ?", 24.hours.ago)
        .where("carts.updated_at > ?", 7.days.ago)
        .distinct
        .each do |cart|
      next unless cart.user&.email.present?

      OrderMailer.abandoned_cart_reminder(cart).deliver_later
      Rails.logger.info "Sent abandoned cart reminder to #{cart.user.email}"
    end
  end
end
