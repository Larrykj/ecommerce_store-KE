# frozen_string_literal: true

class LoyaltyController < ApplicationController
  before_action :authenticate_user!

  def show
    @program = LoyaltyProgram.where(active: true).first
    @points = current_user.loyalty_points.available.sum(:points)
    @tier = @program&.current_tier(current_user)
    @history = current_user.loyalty_points.order(created_at: :desc).limit(20)
    @rewards = @program&.rewards&.where(active: true)
    @my_rewards = current_user.user_rewards.unused
  end

  def rewards
    @program = LoyaltyProgram.where(active: true).first
    @points = current_user.loyalty_points.available.sum(:points)
    @rewards = @program&.rewards&.where(active: true)
    render :show
  end

  def redeem
    @program = LoyaltyProgram.where(active: true).first
    reward = @program&.rewards&.find_by(id: params[:reward_id])

    if reward.nil?
      redirect_to loyalty_path, alert: "Reward not found."
      return
    end

    user_points = current_user.loyalty_points.available.sum(:points)

    if user_points < reward.points_required
      redirect_to loyalty_path, alert: "Not enough points to redeem this reward."
      return
    end

    # Deduct points and create user reward
    current_user.loyalty_points.create!(
      points: -reward.points_required,
      reason: "Redeemed: #{reward.name}",
      redeemed: true
    )

    current_user.user_rewards.create!(loyalty_reward: reward)

    redirect_to loyalty_path, notice: "Successfully redeemed #{reward.name}!"
  end
end
