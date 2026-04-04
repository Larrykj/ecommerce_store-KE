# frozen_string_literal: true

class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items
  belongs_to :promo_code, optional: true
  belongs_to :shipping_method, optional: true
  belongs_to :gift_card, optional: true

  TAX_RATE = 0.16 # 16% VAT

  validate :promo_code_must_be_valid

  def subtotal
    cart_items.includes(:variant).to_a.sum(&:subtotal)
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

  def pre_gift_card_total
    [ subtotal - discount_amount, 0 ].max + shipping_cost + tax_amount
  end

  def gift_card_amount
    return 0 unless gift_card&.active?
    [ gift_card.balance, pre_gift_card_total ].min
  end

  def total_price
    pre_gift_card_total - gift_card_amount
  end

  def total_items
    @total_items ||= (cart_items.loaded? ? cart_items.to_a.sum(&:quantity) : cart_items.sum(:quantity))
  end

  private

  def promo_code_must_be_valid
    return unless promo_code_id_changed?
    return if promo_code.nil?
    errors.add(:promo_code, "is invalid or expired") unless promo_code.valid_for_cart?(self)
  end
end
