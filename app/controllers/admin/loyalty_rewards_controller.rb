class Admin::LoyaltyRewardsController < Admin::BaseController
  def create
    program = LoyaltyProgram.first_or_create!(name: "Default Program")
    reward = program.rewards.build(reward_params)

    if reward.save
      redirect_to admin_loyalty_programs_path, notice: "Reward successfully configured."
    else
      redirect_to admin_loyalty_programs_path, alert: reward.errors.full_messages.to_sentence
    end
  end

  def destroy
    reward = LoyaltyReward.find(params[:id])
    reward.destroy
    redirect_to admin_loyalty_programs_path, notice: "Reward removed."
  end

  private

  def reward_params
    # Standardize handling of params regardless if view provides scoped inputs
    if params[:loyalty_reward]
      params.require(:loyalty_reward).permit(:name, :description, :points_required, :discount_percent, :discount_amount, :max_redemptions, :active)
    else
      params.permit(:name, :description, :points_required, :discount_percent, :discount_amount, :max_redemptions, :active)
    end
  end
end
