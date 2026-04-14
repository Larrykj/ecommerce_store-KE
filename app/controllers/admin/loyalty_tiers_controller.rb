class Admin::LoyaltyTiersController < Admin::BaseController
  def create
    program = LoyaltyProgram.first_or_create!(name: "Default Program")
    tier = program.tiers.build(tier_params)

    if tier.save
      redirect_to admin_loyalty_programs_path, notice: "Tier successfully added."
    else
      redirect_to admin_loyalty_programs_path, alert: tier.errors.full_messages.to_sentence
    end
  end

  def destroy
    tier = LoyaltyTier.find(params[:id])
    tier.destroy
    redirect_to admin_loyalty_programs_path, notice: "Tier removed."
  end

  private

  def tier_params
    # Accept both scoped and unscoped depending on how the view submitted it
    if params[:loyalty_tier]
      params.require(:loyalty_tier).permit(:name, :min_points, :points_multiplier, :discount_percent, :badge_color)
    else
      params.permit(:name, :min_points, :points_multiplier, :discount_percent, :badge_color)
    end
  end
end
