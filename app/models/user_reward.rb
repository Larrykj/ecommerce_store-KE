class UserReward < ApplicationRecord
  belongs_to :user
  belongs_to :loyalty_reward
  belongs_to :order, optional: true

  scope :unused, -> { where(used: false) }
  scope :used, -> { where(used: true) }

  def redeem!
    update!(used: true)
    loyalty_reward.increment!(:redemption_count)
  end
end
