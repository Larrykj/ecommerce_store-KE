class Product < ApplicationRecord
  include Discard::Model

  include PgSearch::Model

  belongs_to :category, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :product_views, dependent: :destroy
  has_many :wishlist_items, dependent: :destroy
  has_many :variants, dependent: :destroy
  accepts_nested_attributes_for :variants, allow_destroy: true, reject_if: :all_blank
  has_one_attached :image
  has_many_attached :gallery_images
  has_many :stock_notifications, dependent: :destroy
  has_many :product_comparisons, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { minimum: 3, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validate :acceptable_image

  # ============ SEARCH SCOPES ============

  # Full-text search using pg_search
  pg_search_scope :search_by_text,
                  against: [ :name, :description ],
                  associated_against: {
                    category: [ :name ],
                    variants: [ :sku, :name ]
                  },
                  using: {
                    tsearch: { prefix: true }
                  }

  # Filter by category
  scope :by_category, ->(category_id) {
    return all if category_id.blank?

    where(category_id: category_id)
  }

  # Filter by price range
  scope :by_min_price, ->(min_price) {
    return all if min_price.blank?

    where("price >= ?", min_price.to_f)
  }

  scope :by_max_price, ->(max_price) {
    return all if max_price.blank?

    where("price <= ?", max_price.to_f)
  }

  # Filter by stock status
  scope :in_stock_only, -> { joins(:variants).where("variants.quantity > 0").distinct }
  scope :out_of_stock_only, -> { left_outer_joins(:variants).group("products.id").having("SUM(COALESCE(variants.quantity, 0)) = 0") }

  scope :by_stock_status, ->(status) {
    case status
    when "in_stock"
      in_stock_only
    when "out_of_stock"
      out_of_stock_only
    else
      all
    end
  }

  # Sorting scopes
  scope :sorted_by, ->(sort_option) {
    case sort_option
    when "price_asc"
      order(price: :asc)
    when "price_desc"
      order(price: :desc)
    when "name_asc"
      order(name: :asc)
    when "name_desc"
      order(name: :desc)
    when "newest"
      order(created_at: :desc)
    when "oldest"
      order(created_at: :asc)
    else
      order(created_at: :desc)
    end
  }

  # Combined search method - chains all filters together
  def self.advanced_search(params)
    results = kept
    results = results.search_by_text(params[:search]) if params[:search].present?
    results = results.by_category(params[:category_id])
    results = results.by_min_price(params[:min_price])
    results = results.by_max_price(params[:max_price])
    results = results.by_stock_status(params[:stock_status])
    results.sorted_by(params[:sort])
  end

  # Get price statistics for filter UI
  def self.price_stats
    {
      min: minimum(:price)&.to_f || 0,
      max: maximum(:price)&.to_f || 0,
      avg: average(:price)&.to_f&.round(2) || 0
    }
  end

  # ============ INSTANCE METHODS ============

  # Validate image size and type
  def acceptable_image
    return unless image.attached?

    unless image.blob.byte_size <= 5.megabytes
      errors.add(:image, "is too big (max 5MB)")
    end

    acceptable_types = ["image/jpeg", "image/png", "image/webp"]
    unless acceptable_types.include?(image.content_type)
      errors.add(:image, "must be a JPEG, PNG or WebP")
    end
  end

  # Total stock across all variants
  def quantity
    variants.sum(:quantity)
  end

  # Check if product is in stock
  def in_stock?
    total_qty = respond_to?(:variants) ? variants.sum(:quantity) : (self[:quantity] || 0)
    total_qty > 0
  end

  # Format price for display in KSH
  def formatted_price
    "KSh #{price.round(2)}"
  end

  # Stock status label
  def stock_status_label
    total_qty = respond_to?(:variants) ? variants.sum(:quantity) : (self[:quantity] || 0)
    if total_qty.zero?
      I18n.t("out_of_stock")
    elsif total_qty <= 5
      I18n.t("low_stock", count: total_qty)
    else
      I18n.t("in_stock_with_count", count: total_qty)
    end
  end

  # Stock status badge class for Bootstrap
  def stock_status_class
    total_qty = respond_to?(:variants) ? variants.sum(:quantity) : (self[:quantity] || 0)
    if total_qty.zero?
      "danger"
    elsif total_qty <= 5
      "warning"
    else
      "success"
    end
  end

  # ============ RATING METHODS ============

  # Get average rating for product
  def average_rating
    reviews.average(:rating)&.round(1) || 0
  end

  # Get review count
  def reviews_count
    reviews.count
  end

  # Get rating percentage (for progress bars)
  def rating_percentage
    (average_rating / 5.0 * 100).round
  end

  # Get rating distribution (count of each star level)
  def rating_distribution
    distribution = { 5 => 0, 4 => 0, 3 => 0, 2 => 0, 1 => 0 }
    reviews.group(:rating).count.each do |rating, count|
      distribution[rating] = count if distribution.key?(rating)
    end
    distribution
  end

  # Check if user has already reviewed this product
  def reviewed_by?(user)
    return false unless user
    reviews.exists?(user_id: user.id)
  end

  # Get user's review for this product
  def review_by(user)
    return nil unless user
    reviews.find_by(user_id: user.id)
  end
end
