class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :variant
  has_one :product, through: :variant

  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }

  # Calculate subtotal for this item
  def subtotal
    (variant&.price || 0) * quantity
  end

  # Format subtotal in KSH
  def formatted_subtotal
    "KSh #{subtotal.round(2)}"
  end
end
