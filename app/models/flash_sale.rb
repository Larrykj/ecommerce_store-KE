class FlashSale < ApplicationRecord
  validates_with OverlapValidator
  has_many :flash_sale_products, dependent: :destroy
  has_many :products, through: :flash_sale_products

  validates :name, :start_time, :end_time, presence: true

  scope :active, -> { where(active: true) }
  scope :current, -> { active.where("start_time <= ? AND end_time >= ?", Time.current, Time.current) }
  scope :upcoming, -> { active.where("start_time > ?", Time.current) }

  def self.current_flash_sale_product_for(product)
    current.joins(:flash_sale_products).find_by(flash_sale_products: { product_id: product.id })&.flash_sale_products&.find_by(product: product)
  end

  def self.current_special_price_for(product)
    current_flash_sale_product_for(product)&.special_price
  end

  def active?
    active && start_time <= Time.current && end_time >= Time.current
  end

  def upcoming?
    active && start_time > Time.current
  end

  def remaining_quantity(product)
    fsp = flash_sale_products.find_by(product: product)
    return nil unless fsp
    fsp.max_quantity - fsp.sold_count
  end
end
