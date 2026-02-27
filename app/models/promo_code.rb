# frozen_string_literal: true

class PromoCode < ApplicationRecord
  has_many :orders

  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :discount_type, presence: true, inclusion: { in: %w[percentage flat] }
  validates :discount_value, presence: true, numericality: { greater_than: 0 }
  validates :min_order_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :max_uses, numericality: { greater_than: 0, only_integer: true }, allow_nil: true

  scope :active, -> { where(active: true).where("expires_at IS NULL OR expires_at > ?", Time.current) }

  before_validation :upcase_code

  def valid_for_cart?(cart)
    return false unless active?
    return false if expires_at.present? && expires_at < Time.current
    return false if max_uses.present? && current_uses >= max_uses
    return false if min_order_amount.present? && cart.subtotal < min_order_amount
    true
  end

  def calculate_discount(subtotal)
    if discount_type == "percentage"
      (subtotal * (discount_value / 100.0)).round(2)
    else
      [ discount_value, subtotal ].min
    end
  end

  def increment_usage!
    increment!(:current_uses)
  end

  private

  def upcase_code
    self.code = code.to_s.upcase.strip
  end
end
