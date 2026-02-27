# frozen_string_literal: true

class ProductComparison < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :product

  validate :max_comparison_count

  private

  def max_comparison_count
    scope = user_id? ? ProductComparison.where(user_id: user_id) : ProductComparison.where(session_id: session_id)
    if scope.where.not(id: id).count >= 4
      errors.add(:base, "You can compare up to 4 products at a time")
    end
  end
end
