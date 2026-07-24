# frozen_string_literal: true

class ShippingMethod < ApplicationRecord
  has_many :orders, dependent: :nullify
  has_many :carts, dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :base_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :estimated_days, presence: true, numericality: { only_integer: true, greater_than: 0 }

  scope :active, -> { where(active: true) }
end
