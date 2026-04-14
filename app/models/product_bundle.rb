class ProductBundle < ApplicationRecord
  has_many :items, class_name: "BundleItem", foreign_key: "bundle_id", dependent: :destroy
  has_many :products, through: :items

  validates :name, :slug, :price, presence: true
  validates :slug, uniqueness: true

  before_validation :set_slug

  scope :active, -> { where(active: true) }

  def set_slug
    self.slug ||= name.parameterize
  end

  def to_param
    slug
  end

  def savings
    return 0 unless original_price
    original_price - price
  end
end
