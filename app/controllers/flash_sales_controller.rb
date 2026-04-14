class FlashSalesController < ApplicationController
  def index
    @pagy, @sales = pagy(FlashSale.current.or(FlashSale.upcoming).order(start_time: :desc))
  end

  def show
    @flash_sale = FlashSale.active.find(params[:id])
  end
end
