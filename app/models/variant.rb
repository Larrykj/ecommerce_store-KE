class Variant < ApplicationRecord
  belongs_to :product
  has_many :cart_items, dependent: :restrict_with_error
  has_many :order_items, dependent: :restrict_with_error

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :sku, uniqueness: true, allow_blank: true

  def in_stock?
    quantity > 0
  end
end
