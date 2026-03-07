# frozen_string_literal: true

class ProductsController < ApplicationController
  before_action :set_product, only: [ :show ]
  after_action :track_view, only: [ :show ]
  # GET /products
  def index
    @categories = Category.all
    @price_stats = Product.price_stats
    @pagy, @products = pagy(Product.advanced_search(search_params), items: 12)
    @active_filters_count = count_active_filters
    @search_params = search_params

    if current_user
      @recommended_products = current_user.recommended_products
      @wishlist_map = current_user.wishlist_items.index_by(&:product_id)
    else
      @recommended_products = []
      @wishlist_map = {}
    end
  end

  # GET /products/:id
  def show
  end


  private

  def track_view
    if current_user
      ProductView.create(user: current_user, product: @product)
    end
  rescue => e
    Rails.logger.error("Failed to track view: #{e.message}")
  end

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :image, :category_id, gallery_images: [])
  end

  def search_params
    params.permit(:search, :category_id, :min_price, :max_price, :stock_status, :sort).to_h.symbolize_keys
  end

  def count_active_filters
    count = 0
    count += 1 if params[:search].present?
    count += 1 if params[:category_id].present?
    count += 1 if params[:min_price].present? || params[:max_price].present?
    count += 1 if params[:stock_status].present?
    count += 1 if params[:sort].present?
    count
  end
end
# EOF
