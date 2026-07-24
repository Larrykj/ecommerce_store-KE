# frozen_string_literal: true

# Cleans up abandoned carts that have no items and are older than the retention period.
# This prevents unbounded growth of the carts table from bot visits and expired sessions.
class CleanupAbandonedCartsJob < ApplicationJob
  queue_as :default

  RETENTION_PERIOD = 30.days

  def perform
    # Only delete carts that are old AND empty (no cart items)
    abandoned = Cart.where("updated_at < ?", RETENTION_PERIOD.ago)
                    .left_joins(:cart_items)
                    .where(cart_items: { id: nil })

    count = abandoned.count
    abandoned.delete_all

    Rails.logger.info "[CleanupAbandonedCartsJob] Deleted #{count} abandoned carts older than #{RETENTION_PERIOD.inspect}"
  end
end
