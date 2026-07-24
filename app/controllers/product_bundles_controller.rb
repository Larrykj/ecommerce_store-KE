class ProductBundlesController < ApplicationController
  def index
    @pagy, @bundles = pagy(ProductBundle.active.includes(items: :product))
  end

  def show
    @bundle = ProductBundle.active.includes(items: :product).find_by!(slug: params[:id])
  end
end
