class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items
  belongs_to :promo_code, optional: true
  belongs_to :shipping_method, optional: true

  TAX_RATE = 0.16 # 16% VAT

  def subtotal
    cart_items.sum { |item| item.subtotal }
  end

  def discount_amount
    return 0 unless promo_code&.valid_for_cart?(self)
    promo_code.calculate_discount(subtotal)
  end

  def shipping_cost
    shipping_method&.base_rate || 0
  end

  def tax_amount
    ([ subtotal - discount_amount, 0 ].max * TAX_RATE).round(2)
  end

  def total_price
    [ subtotal - discount_amount, 0 ].max + shipping_cost + tax_amount
  end

  def total_items
    cart_items.sum(:quantity)
  end
end
