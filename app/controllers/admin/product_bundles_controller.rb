class Admin::ProductBundlesController < Admin::BaseController
  def index
    @pagy, @bundles = pagy(ProductBundle.all.order(created_at: :desc))
  end

  def new
    @bundle = ProductBundle.new
  end

  def create
    @bundle = ProductBundle.new(bundle_params)
    if @bundle.save
      redirect_to admin_product_bundles_path, notice: "Bundle created!"
    else
      render :new
    end
  end

  def edit
    @bundle = ProductBundle.find(params[:id])
  end

  def update
    @bundle = ProductBundle.find(params[:id])
    if @bundle.update(bundle_params)
      redirect_to admin_product_bundles_path, notice: "Bundle updated!"
    else
      render :edit
    end
  end

  def destroy
    ProductBundle.find(params[:id]).destroy
    redirect_to admin_product_bundles_path
  end

  def add_product
    @bundle = ProductBundle.find(params[:id])
    @bundle.items.create!(
      product_id: params[:product_id],
      quantity: params[:quantity] || 1
    )
    redirect_to edit_admin_product_bundle_path(@bundle), notice: "Product added to bundle."
  end

  def remove_product
    @bundle = ProductBundle.find(params[:id])
    @bundle.items.find_by(product_id: params[:product_id])&.destroy
    redirect_to edit_admin_product_bundle_path(@bundle), notice: "Product removed."
  end

  private

  def bundle_params
    params.require(:product_bundle).permit(:name, :slug, :description, :price, :original_price, :discount_percent, :active, :max_quantity)
  end
end
