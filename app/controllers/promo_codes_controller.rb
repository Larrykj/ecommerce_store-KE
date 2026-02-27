# frozen_string_literal: true

class PromoCodesController < ApplicationController
  def apply
    promo_code = PromoCode.find_by(code: params[:code].to_s.upcase.strip)

    if promo_code&.valid_for_cart?(@cart)
      @cart.update!(promo_code: promo_code)
      redirect_back fallback_location: cart_path, notice: "Promo code successfully applied!"
    else
      redirect_back fallback_location: cart_path, alert: "Invalid or expired promo code."
    end
  end

  def remove
    @cart.update!(promo_code: nil)
    redirect_back fallback_location: cart_path, notice: "Promo code removed."
  end
end
