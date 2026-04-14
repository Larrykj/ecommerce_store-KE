class LoyaltyReward < ApplicationRecord
  belongs_to :loyalty_program

  has_many :user_rewards, dependent: :destroy

  validates :name, :points_required, presence: true

  scope :active, -> { where(active: true) }

  def available?
    active && (max_redemptions.nil? || redemption_count < max_redemptions)
  end
end
