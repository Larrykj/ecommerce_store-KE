class CartItemsController < ApplicationController
  before_action :set_cart_item, only: [ :update, :destroy ]

  # POST /cart_items
  def create
    # ── Bundle add-to-cart ──
    if params[:bundle_id].present?
      bundle = ProductBundle.find(params[:bundle_id])
      added = 0
      skipped = 0

      bundle.items.includes(product: :variants).each do |bundle_item|
        variant = bundle_item.product.first_available_variant
        unless variant
          skipped += 1
          next
        end

        qty = bundle_item.quantity || 1
        existing = @cart.cart_items.find_by(variant: variant)

        if existing
          new_qty = existing.quantity + qty
          if new_qty <= variant.quantity
            existing.update(quantity: new_qty)
            added += 1
          else
            skipped += 1
          end
        else
          if qty <= variant.quantity
            @cart.cart_items.create(variant: variant, quantity: qty)
            added += 1
          else
            skipped += 1
          end
        end
      end

      notice = "#{added} product#{'s' if added != 1} from \"#{bundle.name}\" added to cart."
      notice += " #{skipped} skipped (out of stock)." if skipped > 0

      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.update("cart-nav-item", partial: "shared/cart_badge"),
            turbo_stream.update("cart-nav-item-guest", partial: "shared/cart_badge"),
            turbo_stream.append("toastContainer", partial: "shared/toast", locals: { message: notice, toast_type: skipped > 0 ? "warning" : "success" })
          ]
        }
        format.html { redirect_to cart_path, notice: notice }
      end
      return
    end

    # ── Single variant add-to-cart ──
    variant = Variant.find(params[:variant_id])
    @cart_item = @cart.cart_items.find_by(variant: variant)

    respond_to do |format|
      if @cart_item
        if @cart_item.quantity + 1 > variant.quantity
          format.turbo_stream { render turbo_stream: turbo_stream.append("toastContainer", partial: "shared/toast", locals: { message: t("not_enough_stock", default: "Not enough stock available"), toast_type: "error" }) }
          format.html { redirect_to cart_path, alert: t("not_enough_stock") }
        else
          @cart_item.quantity += 1
          @cart_item.save
          format.turbo_stream {
            render turbo_stream: [
              turbo_stream.update("cart-nav-item", partial: "shared/cart_badge"),
              turbo_stream.update("cart-nav-item-guest", partial: "shared/cart_badge"),
              turbo_stream.append("toastContainer", partial: "shared/toast", locals: { message: t("cart_quantity_updated", default: "Cart updated!"), toast_type: "success" })
            ]
          }
          format.html { redirect_to cart_path, notice: t("cart_quantity_updated") }
        end
      else
        if variant.quantity < 1
          format.turbo_stream { render turbo_stream: turbo_stream.append("toastContainer", partial: "shared/toast", locals: { message: t("not_enough_stock", default: "Not enough stock available"), toast_type: "error" }) }
          format.html { redirect_to cart_path, alert: t("not_enough_stock") }
        else
          @cart_item = @cart.cart_items.create(variant: variant, quantity: 1)
          format.turbo_stream {
            render turbo_stream: [
              turbo_stream.update("cart-nav-item", partial: "shared/cart_badge"),
              turbo_stream.update("cart-nav-item-guest", partial: "shared/cart_badge"),
              turbo_stream.append("toastContainer", partial: "shared/toast", locals: { message: t("cart_product_added", default: "Added to cart!"), toast_type: "success" })
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
        format.turbo_stream { render turbo_stream: turbo_stream.append("toastContainer", partial: "shared/toast", locals: { message: t("not_enough_stock", default: "Not enough stock available"), toast_type: "error" }) }
        format.html { redirect_to cart_path, alert: t("not_enough_stock") }
      elsif @cart_item.update(quantity: new_quantity)
        setup_cart_variables
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.update("cart-nav-item", partial: "shared/cart_badge"),
            turbo_stream.update("cart-nav-item-guest", partial: "shared/cart_badge"),
            turbo_stream.replace("cart-page-content", template: "carts/show", layout: false)
          ]
        }
        format.html { redirect_to cart_path, notice: t("quantity_updated") }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.append("toastContainer", partial: "shared/toast", locals: { message: t("quantity_update_failed"), toast_type: "error" }) }
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
          turbo_stream.update("cart-nav-item", partial: "shared/cart_badge"),
          turbo_stream.update("cart-nav-item-guest", partial: "shared/cart_badge"),
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
