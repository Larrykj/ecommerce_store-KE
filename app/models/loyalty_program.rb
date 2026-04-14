class LoyaltyProgram < ApplicationRecord
  has_many :tiers, class_name: "LoyaltyTier", dependent: :destroy
  has_many :rewards, class_name: "LoyaltyReward", dependent: :destroy

  validates :name, presence: true

  scope :active, -> { where(active: true) }

  def active?
    active
  end

  def current_tier(user)
    user_points = user.loyalty_points.where(redeemed: false).sum(:points)
    tiers.where("min_points <= ?", user_points).order(min_points: :desc).first
  end

  def calculate_points(amount)
    (amount * points_per_dollar).to_i
  end
end
