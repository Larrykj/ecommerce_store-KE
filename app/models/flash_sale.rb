class FlashSale < ApplicationRecord
  validates_with OverlapValidator
  has_many :flash_sale_products, dependent: :destroy
  has_many :products, through: :flash_sale_products

  validates :name, :start_time, :end_time, presence: true

  scope :active, -> { where(active: true) }
  scope :current, -> { active.where("start_time <= ? AND end_time >= ?", Time.current, Time.current) }
  scope :upcoming, -> { active.where("start_time > ?", Time.current) }

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
