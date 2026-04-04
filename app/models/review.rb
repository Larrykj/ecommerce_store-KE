# frozen_string_literal: true

class Review < ApplicationRecord
  belongs_to :user
  belongs_to :product

  # Update product review cache after create/destroy
  after_create :update_product_cache
  after_destroy :update_product_cache

  # Validations
  # Validations
  validates :rating, presence: true, inclusion: { in: 1..5, message: ->(_object, _data) { I18n.t("errors.messages.rating_between") } }
  validates :title, length: { maximum: 100 }, allow_blank: true
  validates :content, length: { minimum: 10, maximum: 1000 }, allow_blank: false
  validates :user_id, uniqueness: { scope: :product_id, message: ->(_object, _data) { I18n.t("errors.messages.already_reviewed_product") } }

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :highest_rated, -> { order(rating: :desc) }
  scope :lowest_rated, -> { order(rating: :asc) }
  scope :most_helpful, -> { order(helpful_count: :desc) }
  scope :by_rating, ->(rating) { where(rating: rating) if rating.present? }

  # Instance methods
  def rating_label
    case rating
    when 5 then I18n.t("review.rating_labels.excellent")
    when 4 then I18n.t("review.rating_labels.very_good")
    when 3 then I18n.t("review.rating_labels.good")
    when 2 then I18n.t("review.rating_labels.fair")
    when 1 then I18n.t("review.rating_labels.poor")
    end
  end

  def formatted_date
    I18n.l(created_at, format: :long)
  end

  def mark_helpful!
    increment!(:helpful_count)
  end

  # Check if user can edit this review
  def editable_by?(user)
    return false unless user
    self.user_id == user.id
  end

  private

  # Update the product's review cache when a review is created or destroyed
  def update_product_cache
    product.update_review_cache if product
  end
end
