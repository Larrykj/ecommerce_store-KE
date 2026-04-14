class LoyaltyPoint < ApplicationRecord
  belongs_to :user
  belongs_to :order, optional: true

  validates :points, :reason, presence: true

  scope :available, -> { where(redeemed: false) }
  scope :redeemed, -> { where(redeemed: true) }

  after_create :update_user_tier

  private

  def update_user_tier
    LoyaltyTierUpdateJob.perform_later(user.id)
  end
end
