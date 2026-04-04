# frozen_string_literal: true

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

  # Bump API cache version when product data changes
  after_save :bump_api_cache_version
  after_destroy :bump_api_cache_version

  # ============ SEARCH SCOPES ============

  pg_search_scope :search_by_text,
                  against: [ :name, :description ],
                  associated_against: {
                    category: [ :name ],
                    variants: [ :sku, :name ]
                  },
                  using: {
                    tsearch: { prefix: true }
                  }

  scope :by_category, ->(category_id) {
    return all if category_id.blank?
    where(category_id: category_id)
  }

  scope :by_min_price, ->(min_price) {
    return all if min_price.blank?
    where(arel_table[:price].gteq(min_price.to_f))
  }

  scope :by_max_price, ->(max_price) {
    return all if max_price.blank?
    where(arel_table[:price].lteq(max_price.to_f))
  }

  scope :in_stock_only, -> { joins(:variants).where("variants.quantity > 0").distinct }
  scope :out_of_stock_only, -> { left_outer_joins(:variants).group(:id).having(Arel.sql("SUM(COALESCE(variants.quantity, 0)) = 0")) }

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

  scope :sorted_by, ->(sort_option) {
    case sort_option
    when "price_asc"
      order(arel_table[:price].asc)
    when "price_desc"
      order(arel_table[:price].desc)
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

  def self.advanced_search(params)
    results = kept
    results = results.search_by_text(params[:search]) if params[:search].present?
    results = results.by_category(params[:category_id])
    results = results.by_min_price(params[:min_price])
    results = results.by_max_price(params[:max_price])
    results = results.by_stock_status(params[:stock_status])
    results.sorted_by(params[:sort])
  end

  def self.price_stats
    Rails.cache.fetch("products/price_stats", expires_in: 1.hour) do
      {
        min: minimum(:price)&.to_f || 0,
        max: maximum(:price)&.to_f || 0,
        avg: average(:price)&.to_f&.round(2) || 0
      }
    end
  end

  # ============ INSTANCE METHODS ============

  def acceptable_image
    return unless image.attached?

    unless image.blob.byte_size <= 5.megabytes
      errors.add(:image, "is too big (max 5MB)")
    end

    acceptable_types = [ "image/jpeg", "image/png", "image/webp" ]
    unless acceptable_types.include?(image.content_type)
      errors.add(:image, "must be a JPEG, PNG or WebP")
    end
  end

  # Total stock — uses in-memory sum if variants are already loaded
  def quantity
    if variants.loaded?
      variants.to_a.sum(&:quantity)
    else
      variants.sum(:quantity)
    end
  end

  # Stock check — uses in-memory if variants are loaded
  def in_stock?
    if variants.loaded?
      variants.any? { |v| v.quantity > 0 }
    else
      variants.exists?([ "quantity > 0" ])
    end
  end

  # In-stock variants — avoids extra query if already loaded
  def in_stock_variants
    if variants.loaded?
      variants.select { |v| v.quantity > 0 }
    else
      variants.where("quantity > 0")
    end
  end

  # First available variant — avoids extra query if already loaded
  def first_available_variant
    in_stock_variants.first
  end

  # Reviews check — uses loaded association when available
  def reviewed_by?(user)
    return false unless user
    if reviews.loaded?
      reviews.any? { |r| r.user_id == user.id }
    else
      reviews.exists?(user_id: user.id)
    end
  end

  def review_by(user)
    return nil unless user
    if reviews.loaded?
      reviews.find { |r| r.user_id == user.id }
    else
      reviews.find_by(user_id: user.id)
    end
  end

  def formatted_price
    "KSh #{price.round(2)}"
  end

  def stock_status_label
    total_qty = quantity
    if total_qty.zero?
      I18n.t("out_of_stock", default: "Out of Stock")
    elsif total_qty <= 5
      I18n.t("low_stock", count: total_qty, default: "Low Stock (#{total_qty})")
    else
      I18n.t("in_stock_with_count", count: total_qty, default: "In Stock (#{total_qty})")
    end
  end

  def stock_status_class
    total_qty = quantity
    if total_qty.zero?
      "danger"
    elsif total_qty <= 5
      "warning"
    else
      "success"
    end
  end

  # ============ RATING METHODS ============

  def average_rating
    self[:average_rating] || 0
  end

  def reviews_count
    self[:reviews_count] || 0
  end

  def rating_percentage
    (average_rating / 5.0 * 100).round
  end

  def rating_distribution
    distribution = { 5 => 0, 4 => 0, 3 => 0, 2 => 0, 1 => 0 }
    reviews.each do |r|
      distribution[r.rating] += 1 if distribution.key?(r.rating)
    end
    distribution
  end

  def update_review_cache
    self.reviews_count = reviews.count
    self.average_rating = reviews.average(:rating)&.round(2) || 0
    save(validate: false)
  end

  private

  def bump_api_cache_version
    Rails.cache.write("api/v1/products/cache_version", SecureRandom.hex(4))
  end
end
