# frozen_string_literal: true

class ComparisonsController < ApplicationController
  def show
    if user_signed_in?
      @comparisons = current_user.product_comparisons.includes(:product)
    else
      @comparisons = ProductComparison.where(session_id: session.id.to_s).includes(:product)
    end
    @products = @comparisons.map(&:product).compact
  end

  def add
    product = Product.find(params[:product_id])
    comparison = ProductComparison.new(
      product: product,
      user: current_user,
      session_id: session.id.to_s
    )

    if comparison.save
      redirect_back fallback_location: product_path(product), notice: "#{product.name} added to comparison."
    else
      redirect_back fallback_location: product_path(product), alert: comparison.errors.full_messages.first
    end
  end

  def remove
    if user_signed_in?
      comparison = current_user.product_comparisons.find_by(product_id: params[:product_id])
    else
      comparison = ProductComparison.find_by(session_id: session.id.to_s, product_id: params[:product_id])
    end
    comparison&.destroy
    redirect_back fallback_location: comparison_path, notice: "Product removed from comparison."
  end

  def clear
    if user_signed_in?
      current_user.product_comparisons.destroy_all
    else
      ProductComparison.where(session_id: session.id.to_s).destroy_all
    end
    redirect_to comparison_path, notice: "Comparison list cleared."
  end
end
