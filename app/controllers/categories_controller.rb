class CategoriesController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_category, only: [ :show, :edit, :update, :destroy ]

  def index
    @categories = Category.advanced_search(search_params)
    @active_filters_count = count_active_filters
    @search_params = search_params
  end

  def show
    # Get products with filtering
    @products = @category.products
    @products = @products.search_by_text(params[:search]) if params[:search].present?
    @products = @products.by_min_price(params[:min_price])
                         .by_max_price(params[:max_price])
                         .by_stock_status(params[:stock_status])
                         .sorted_by(params[:sort])

    @price_stats = @category.products.price_stats
    @active_filters_count = count_active_filters
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to categories_path, notice: t("category_created_success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to @category, notice: t("category_updated_success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    redirect_to categories_path, notice: t("category_deleted_success")
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :description, :image)
  end

  def search_params
    params.permit(:search, :sort).to_h.symbolize_keys
  end

  def count_active_filters
    count = 0
    count += 1 if params[:search].present?
    count += 1 if params[:min_price].present? || params[:max_price].present?
    count += 1 if params[:stock_status].present?
    count += 1 if params[:sort].present?
    count
  end
end
