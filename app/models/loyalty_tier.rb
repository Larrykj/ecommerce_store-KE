class LoyaltyTier < ApplicationRecord
  belongs_to :loyalty_program

  validates :name, :min_points, presence: true

  def self.for_points(points)
    where("min_points <= ?", points).order(min_points: :desc).first
  end
end
