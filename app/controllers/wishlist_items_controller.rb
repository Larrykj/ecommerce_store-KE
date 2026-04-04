# frozen_string_literal: true

class WishlistItemsController < ApplicationController
  before_action :authenticate_user!

  def index
    @products = current_user.wishlist_products
  end

  def create
    @product = Product.find(params[:product_id])

    unless current_user.wishlist_products.include?(@product)
      current_user.wishlist_products << @product
      respond_to do |format|
        format.turbo_stream { render turbo_stream: [
          turbo_stream.replace("wishlist-btn-#{@product.id}", partial: "shared/wishlist_button", locals: { product: @product }),
          turbo_stream.append("toastContainer", "<script>showToast('#{t("wishlist_added_success")}', 'success')</script>".html_safe)
        ] }
        format.html { redirect_back fallback_location: products_path, notice: t("wishlist_added_success") }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.append("toastContainer", "<script>showToast('#{t("wishlist_already_exists")}', 'warning')</script>".html_safe) }
        format.html { redirect_back fallback_location: products_path, alert: t("wishlist_already_exists") }
      end
    end
  end

  def destroy
    # Can be destroyed by ID (if passed directly) or product_id lookup
    if params[:id]
      @item = current_user.wishlist_items.find_by(id: params[:id])
    elsif params[:product_id]
      @item = current_user.wishlist_items.find_by(product_id: params[:product_id])
    end

    if @item
      @product = @item.product
      @item.destroy
      respond_to do |format|
        format.turbo_stream { render turbo_stream: [
          turbo_stream.replace("wishlist-btn-#{@product.id}", partial: "shared/wishlist_button", locals: { product: @product }),
          turbo_stream.append("toastContainer", "<script>showToast('#{t("wishlist_removed_success")}', 'success')</script>".html_safe)
        ] }
        format.html { redirect_back fallback_location: products_path, notice: t("wishlist_removed_success") }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.append("toastContainer", "<script>showToast('#{t("wishlist_item_not_found")}', 'error')</script>".html_safe) }
        format.html { redirect_back fallback_location: products_path, alert: t("wishlist_item_not_found") }
      end
    end
  end
end
# EOF
