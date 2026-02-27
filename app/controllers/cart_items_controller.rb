class CartItemsController < ApplicationController
  before_action :set_cart_item, only: [ :update, :destroy ]

  # POST /cart_items
  def create
    variant = Variant.find(params[:variant_id])
    @cart_item = @cart.cart_items.find_by(variant: variant)

    if @cart_item
      # If product already in cart, increase quantity
      @cart_item.quantity += 1
      @cart_item.save
      redirect_to cart_path, notice: t("cart_quantity_updated")
    else
      # Add new variant to cart
      @cart_item = @cart.cart_items.create(variant: variant, quantity: 1)
      redirect_to cart_path, notice: t("cart_product_added")
    end
  end

  # PATCH/PUT /cart_items/:id
  def update
    if @cart_item.update(quantity: params[:quantity])
      redirect_to cart_path, notice: t("quantity_updated")
    else
      redirect_to cart_path, alert: t("quantity_update_failed")
    end
  end

  # DELETE /cart_items/:id
  def destroy
    @cart_item.destroy
    redirect_to cart_path, notice: t("product_removed_from_cart")
  end

  private

  def set_cart_item
    @cart_item = @cart.cart_items.find(params[:id])
  end
end
