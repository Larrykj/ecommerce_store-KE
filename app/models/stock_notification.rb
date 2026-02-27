# frozen_string_literal: true

class StockNotification < ApplicationRecord
  belongs_to :product
  belongs_to :user, optional: true

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: { scope: :product_id, message: "is already subscribed for this product" }

  scope :pending, -> { where(notified: false) }
  scope :for_product, ->(product) { where(product: product) }
end
