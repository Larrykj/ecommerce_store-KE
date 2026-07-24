# frozen_string_literal: true

# Adds a fulfillment timestamp to orders to prevent the double-deduction
# race condition between the Stripe webhook and the checkout success page.
# Whichever handler fires first sets this timestamp; the second skips processing.
class AddFulfillmentProcessedAtToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :fulfillment_processed_at, :datetime, null: true
  end
end
