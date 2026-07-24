# frozen_string_literal: true

class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :variant
  has_one :product, through: :variant

  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }

  def unit_price
    variant&.effective_price || 0
  end

  # Calculate subtotal for this item
  def subtotal
    unit_price * quantity
  end

  # Format subtotal in KSH
  def formatted_subtotal
    "KSh #{subtotal.round(2)}"
  end
end
