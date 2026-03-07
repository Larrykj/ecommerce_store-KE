# frozen_string_literal: true

class Admin::ProductsController < Admin::BaseController
  before_action :set_product, only: [ :show, :edit, :update, :destroy, :restore ]

  def index
    @products = Product.unscoped.order(created_at: :desc)
    @products = @products.where("LOWER(name) LIKE ?", "%#{params[:search].downcase}%") if params[:search].present?
  end

  def show
  end

  def new
    @product = Product.new
    @product.variants.build
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to admin_products_path, notice: "Product created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @product.variants.build if @product.variants.empty?
  end

  def update
    if @product.update(product_params)
      redirect_to admin_products_path, notice: "Product updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.discard
    redirect_to admin_products_path, notice: "Product archived successfully."
  end

  def restore
    @product.undiscard
    redirect_to admin_products_path, notice: "Product restored successfully."
  end

  private

  def set_product
    @product = Product.unscoped.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :image, :category_id, gallery_images: [],
                                    variants_attributes: [ :id, :sku, :name, :price, :quantity, :variant_image, :_destroy ])
  end
end
