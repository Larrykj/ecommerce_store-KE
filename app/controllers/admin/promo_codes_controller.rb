# frozen_string_literal: true

class Admin::PromoCodesController < Admin::BaseController
  before_action :set_promo_code, only: [:edit, :update, :destroy]

  def index
    @pagy, @promo_codes = pagy(PromoCode.order(created_at: :desc), limit: 10)
  end

  def new
    @promo_code = PromoCode.new(active: true)
  end

  def edit
  end

  def create
    @promo_code = PromoCode.new(promo_code_params)

    if @promo_code.save
      redirect_to admin_promo_codes_path, notice: "Promo code created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @promo_code.update(promo_code_params)
      redirect_to admin_promo_codes_path, notice: "Promo code updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @promo_code.destroy
    redirect_to admin_promo_codes_path, notice: "Promo code deleted."
  end

  private

  def set_promo_code
    @promo_code = PromoCode.find(params[:id])
  end

  def promo_code_params
    params.require(:promo_code).permit(:code, :discount_type, :discount_value, :min_order_amount, :max_uses, :expires_at, :active, :description)
  end
end
