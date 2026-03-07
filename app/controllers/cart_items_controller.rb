class CartItemsController < ApplicationController
  before_action :set_cart_item, only: [ :update, :destroy ]

  # POST /cart_items
  def create
    variant = Variant.find(params[:variant_id])
    @cart_item = @cart.cart_items.find_by(variant: variant)

    respond_to do |format|
      if @cart_item
        if @cart_item.quantity + 1 > variant.quantity
          format.turbo_stream { render turbo_stream: turbo_stream.append("toastContainer", "<script>showToast('#{t('not_enough_stock', default: 'Not enough stock available')}', 'error')</script>".html_safe) }
          format.html { redirect_to cart_path, alert: t("not_enough_stock") }
        else
          @cart_item.quantity += 1
          @cart_item.save
          format.turbo_stream {
            render turbo_stream: [
              turbo_stream.replace("cart-nav-item", partial: "shared/cart_badge"),
              turbo_stream.replace("cart-nav-item-guest", partial: "shared/cart_badge"),
              turbo_stream.append("toastContainer", "<script>showToast('#{t('cart_quantity_updated', default: 'Cart updated!')}', 'success')</script>".html_safe)
            ]
          }
          format.html { redirect_to cart_path, notice: t("cart_quantity_updated") }
        end
      else
        if variant.quantity < 1
          format.turbo_stream { render turbo_stream: turbo_stream.append("toastContainer", "<script>showToast('#{t('not_enough_stock', default: 'Not enough stock available')}', 'error')</script>".html_safe) }
          format.html { redirect_to cart_path, alert: t("not_enough_stock") }
        else
          @cart_item = @cart.cart_items.create(variant: variant, quantity: 1)
          format.turbo_stream {
            render turbo_stream: [
              turbo_stream.replace("cart-nav-item", partial: "shared/cart_badge"),
              turbo_stream.replace("cart-nav-item-guest", partial: "shared/cart_badge"),
              turbo_stream.append("toastContainer", "<script>showToast('#{t('cart_product_added', default: 'Added to cart!')}', 'success')</script>".html_safe)
            ]
          }
          format.html { redirect_to cart_path, notice: t("cart_product_added") }
        end
      end
    end
  end

  # PATCH/PUT /cart_items/:id
  def update
    respond_to do |format|
      new_quantity = params[:quantity].to_i
      if new_quantity > @cart_item.variant.quantity
        format.turbo_stream { render turbo_stream: turbo_stream.append("toastContainer", "<script>showToast('#{t('not_enough_stock', default: 'Not enough stock available')}', 'error')</script>".html_safe) }
        format.html { redirect_to cart_path, alert: t("not_enough_stock") }
      elsif @cart_item.update(quantity: new_quantity)
        setup_cart_variables
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace("cart-nav-item", partial: "shared/cart_badge"),
            turbo_stream.replace("cart-nav-item-guest", partial: "shared/cart_badge"),
            turbo_stream.replace("cart-page-content", template: "carts/show", layout: false)
          ]
        }
        format.html { redirect_to cart_path, notice: t("quantity_updated") }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.append("toastContainer", "<script>showToast('#{t('quantity_update_failed')}', 'error')</script>".html_safe) }
        format.html { redirect_to cart_path, alert: t("quantity_update_failed") }
      end
    end
  end

  # DELETE /cart_items/:id
  def destroy
    @cart_item.destroy
    setup_cart_variables
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace("cart-nav-item", partial: "shared/cart_badge"),
          turbo_stream.replace("cart-nav-item-guest", partial: "shared/cart_badge"),
          turbo_stream.replace("cart-page-content", template: "carts/show", layout: false)
        ]
      }
      format.html { redirect_to cart_path, notice: t("product_removed_from_cart") }
    end
  end

  private

  def set_cart_item
    @cart_item = @cart.cart_items.find(params[:id])
  end

  def setup_cart_variables
    @cart_items = @cart.cart_items.includes(variant: :product).order(created_at: :desc)
    @shipping_methods = ShippingMethod.where(active: true)
  end
end
