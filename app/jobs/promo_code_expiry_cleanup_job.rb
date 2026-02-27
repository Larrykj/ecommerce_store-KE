# frozen_string_literal: true

class PromoCodeExpiryCleanupJob < ApplicationJob
  queue_as :default

  def perform
    expired_count = PromoCode.where("expiration_date < ?", Date.current)
                             .where.not(active: false)
                             .update_all(active: false)

    Rails.logger.info "Deactivated #{expired_count} expired promo codes"
  end
end
