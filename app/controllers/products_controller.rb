# frozen_string_literal: true

class ProductsController < ApplicationController
  include AdminAuthenticatable

  before_action :set_product, only: [ :show, :edit, :update, :destroy ]
  after_action :track_view, only: [ :show ]

  # GET /products
  def index
    @categories = Category.kept.order(:name)
    @price_stats = Product.price_stats
    base_query = Product.advanced_search(search_params).includes(:category, :variants).with_attached_image
    @pagy, @products = pagy(base_query, items: 12)
    @active_filters_count = count_active_filters
    @search_params = search_params

    # Preload first in-stock variant for each product (avoids N+1 in product_card partial)
    product_ids = @products.map(&:id)
    @first_available_variant = Variant.where(product_id: product_ids)
                                       .where("quantity > 0")
                                       .select(Arel.sql("DISTINCT ON (product_id) product_id, id"))
                                       .order(Arel.sql("product_id, id"))
                                       .index_by(&:product_id)

    if current_user
      @user_view_count = current_user.product_views.count
      @recommended_products = current_user.recommended_products(4).includes(:category, :variants).with_attached_image.to_a
      @wishlist_product_ids = current_user.wishlist_items.where(product_id: product_ids).pluck(:product_id)
      @wishlist_items_by_product = current_user.wishlist_items.where(product_id: product_ids).index_by(&:product_id)

      # Preload recently viewed products (excluding current page products)
      recent_ids = current_user.product_views.order(created_at: :desc).limit(20).pluck(:product_id).uniq.reject { |id| product_ids.include?(id) }.first(4)
      @recently_viewed = recent_ids.present? ? Product.kept.where(id: recent_ids).includes(:category, :variants).with_attached_image.index_by(&:id).values_at(*recent_ids).compact : []
    else
      @user_view_count = 0
      @recommended_products = Product.kept.includes(:category, :variants).with_attached_image.order(created_at: :desc).limit(4).to_a
      @wishlist_product_ids = []
      @wishlist_items_by_product = {}
      @recently_viewed = []
    end

    # Preload category product counts in a single query (avoids N+1 in sidebar)
    @category_product_counts = Category.kept.left_joins(:products).group(:id).pluck(:id, "COUNT(products.id)").to_h
  end

  # GET /products/:id
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # POST /products
  def create
    @product = Product.new(product_params)

    if @product.save
      redirect_to @product, notice: t("product_created_success", default: "Product was successfully created.")
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /products/:id/edit
  def edit
  end

  # PATCH/PUT /products/:id
  def update
    if @product.update(product_params)
      redirect_to @product, notice: t("product_updated_success", default: "Product was successfully updated.")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /products/:id
  def destroy
    @product.destroy
    redirect_to products_url, notice: t("product_deleted_success", default: "Product was successfully deleted.")
  end

  private

  def track_view
    if current_user
      # Throttle: only record once per user/product per hour to prevent unbounded growth
      recent_view = ProductView.where(user: current_user, product: @product)
                               .where("created_at > ?", 1.hour.ago)
                               .exists?
      ProductView.create(user: current_user, product: @product) unless recent_view
    end
  rescue => e
    Rails.logger.error("Failed to track view: #{e.message}")
  end

  def set_product
    @product = Product.with_attached_image.with_attached_gallery_images.includes(:category, :variants, reviews: :user).find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :image, :category_id, gallery_images: [], variants_attributes: [ :id, :name, :sku, :price, :quantity, :_destroy ])
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
