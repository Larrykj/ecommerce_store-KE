class CartsController < ApplicationController
  def show
    @cart_items = @cart.cart_items.includes(:product)
    @shipping_methods = ShippingMethod.active.order(base_rate: :asc)
    # Ensure cart has a default shipping method if one exists
    if @cart.shipping_method.nil? && @shipping_methods.any?
      @cart.update!(shipping_method: @shipping_methods.first)
    end
  end

  def update_shipping
    shipping_method = ShippingMethod.find_by(id: params[:shipping_method_id])
    if shipping_method
      @cart.update!(shipping_method: shipping_method)
    end
    redirect_to cart_path, notice: "Shipping method updated."
  end
end
