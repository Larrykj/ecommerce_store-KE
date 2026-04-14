class LoyaltyTierUpdateJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    program = LoyaltyProgram.active.first
    return unless program

    user_points = user.loyalty_points.available.sum(:points)
    current_tier = program.tiers.for_points(user_points)

    return if user.current_tier_id == current_tier&.id

    user.update!(current_tier_id: current_tier&.id)

    if current_tier && current_tier != user.current_tier
      UserMailer.tier_upgraded(user, current_tier).deliver_later
    end
  end
end
