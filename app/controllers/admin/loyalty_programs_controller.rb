class Admin::LoyaltyProgramsController < Admin::BaseController
  def index
    @program = LoyaltyProgram.first_or_initialize(name: "Default Program")
    @tiers = @program.tiers.order(:min_points)
    @rewards = @program.rewards.order(:points_required)
  end

  def create
    @program = LoyaltyProgram.new(program_params)
    if @program.save
      redirect_to admin_loyalty_programs_path, notice: "Loyalty program created"
    else
      @tiers = @program.tiers.order(:min_points)
      @rewards = @program.rewards.order(:points_required)
      render :index
    end
  end

  def update
    @program = LoyaltyProgram.first_or_create!(name: "Default Program")
    if @program.update(program_params)
      redirect_to admin_loyalty_programs_path, notice: "Loyalty program updated"
    else
      @tiers = @program.tiers.order(:min_points)
      @rewards = @program.rewards.order(:points_required)
      render :index
    end
  end

  def create_tier
    program = LoyaltyProgram.first_or_create!(name: "Default Program")
    program.tiers.create!(tier_params)
    redirect_to admin_loyalty_programs_path
  end

  def destroy_tier
    LoyaltyTier.find(params[:id]).destroy
    redirect_to admin_loyalty_programs_path
  end

  def create_reward
    program = LoyaltyProgram.first_or_create!(name: "Default Program")
    program.rewards.create!(reward_params)
    redirect_to admin_loyalty_programs_path
  end

  def destroy_reward
    LoyaltyReward.find(params[:id]).destroy
    redirect_to admin_loyalty_programs_path
  end

  private

  def program_params
    params.require(:loyalty_program).permit(:name, :points_per_dollar, :minimum_redemption, :active)
  end

  def tier_params
    params.require(:loyalty_tier).permit(:name, :min_points, :points_multiplier, :discount_percent, :badge_color)
  end

  def reward_params
    params.require(:loyalty_reward).permit(:name, :description, :points_required, :discount_percent, :discount_amount, :max_redemptions, :active)
  end
end
