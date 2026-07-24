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

  # Live-computed sum of all component product prices × quantities
  def computed_original_price
    items.includes(:product).sum { |item| (item.product.price || 0) * (item.quantity || 1) }
  end

  def savings
    computed = computed_original_price
    return 0 if computed <= price
    computed - price
  end

  def recalculate_prices!
    old_original = original_price || 0
    computed_original = computed_original_price

    if discount_percent.present? && discount_percent > 0
      self.price = (computed_original * (1 - discount_percent / 100.0)).round(2)
    else
      diff = computed_original - old_original
      if diff != 0 && self.price.present?
        self.price = [ self.price + diff, 0 ].max
      elsif self.price.blank?
        self.price = computed_original
      end
    end

    self.original_price = computed_original
    save!
  end
end
