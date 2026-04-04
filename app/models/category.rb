# frozen_string_literal: true

class Category < ApplicationRecord
  include Discard::Model

  has_many :products, dependent: :nullify
  has_many :reviews, through: :products
  has_one_attached :image

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :description, length: { maximum: 500 }, allow_blank: true

  # Scopes for search and filtering
  scope :search_by_name, ->(query) {
    return all if query.blank?
    where("name ILIKE ?", "%#{query}%")
  }

  scope :with_products, -> { joins(:products).distinct }
  scope :sorted_by, ->(sort_option) {
    case sort_option
    when "name_asc"
      order(name: :asc)
    when "name_desc"
      order(name: :desc)
    when "products_count"
      left_joins(:products).group(:id).order(Arel.sql("COUNT(products.id) DESC"))
    when "newest"
      order(created_at: :desc)
    else
      order(name: :asc)
    end
  }

  # Get average rating across all products in category
  def average_rating
    reviews.average(:rating)&.round(1) || 0
  end

  # Get total review count for category
  def total_reviews_count
    reviews.count
  end

  # Combined search method
  def self.advanced_search(params)
    results = kept
    results = results.search_by_name(params[:search])
    results = results.sorted_by(params[:sort])
    results
  end
end
