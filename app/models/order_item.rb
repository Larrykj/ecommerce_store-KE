class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :variant
  has_one :product, through: :variant

  def formatted_subtotal
    "KSh #{(price * quantity).round(2)}"
  end
end
