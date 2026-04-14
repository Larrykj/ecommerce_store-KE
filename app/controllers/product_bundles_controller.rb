class ProductBundlesController < ApplicationController
  def index
    @pagy, @bundles = pagy(ProductBundle.active)
  end

  def show
    @bundle = ProductBundle.active.find_by!(slug: params[:id])
  end
end
