class LoyaltyService
  def self.award_points(user, amount, reason, order = nil)
    program = LoyaltyProgram.active.first
    return 0 unless program

    points = program.calculate_points(amount)

    tier = program.current_tier(user)
    if tier
      points = (points * tier.points_multiplier).to_i
    end

    LoyaltyPoint.create!(
      user: user,
      order: order,
      points: points,
      reason: reason
    )

    points
  end

  def self.redeem_points(user, points, reason, order = nil)
    available = user.loyalty_points.available.sum(:points)
    return false if available < points

    ActiveRecord::Base.transaction do
      remaining = points
      user.loyalty_points.available.order(created_at: :asc).each do |lp|
        break if remaining <= 0
        deduct = [ lp.points, remaining ].min
        lp.update!(redeemed: true)
        LoyaltyPoint.create!(
          user: user,
          order: order,
          points: -deduct,
          reason: reason
        )
        remaining -= deduct
      end
    end
    true
  end

  def self.redeem_reward(user, reward)
    return false unless reward.available?

    available = user.loyalty_points.available.sum(:points)
    return false if available < reward.points_required

    redeem_points(user, reward.points_required, "Redeemed: #{reward.name}")
    UserReward.create!(user: user, loyalty_reward: reward)
  end
end
