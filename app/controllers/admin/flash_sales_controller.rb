class Admin::FlashSalesController < Admin::BaseController
  def index
    @pagy, @sales = pagy(FlashSale.all.order(start_time: :desc))
  end

  def new
    @flash_sale = FlashSale.new
  end

  def create
    @flash_sale = FlashSale.new(flash_sale_params)
    if @flash_sale.save
      redirect_to admin_flash_sales_path, notice: "Flash sale created!"
    else
      render :new
    end
  end

  def edit
    @flash_sale = FlashSale.find(params[:id])
  end

  def update
    @flash_sale = FlashSale.find(params[:id])
    if @flash_sale.update(flash_sale_params)
      redirect_to admin_flash_sales_path, notice: "Flash sale updated!"
    else
      render :edit
    end
  end

  def destroy
    FlashSale.find(params[:id]).destroy
    redirect_to admin_flash_sales_path
  end

  def add_product
    @flash_sale = FlashSale.find(params[:id])
    @flash_sale.flash_sale_products.create!(
      product_id: params[:product_id],
      special_price: params[:special_price],
      max_quantity: params[:max_quantity]
    )
    redirect_to edit_admin_flash_sale_path(@flash_sale)
  end

  def remove_product
    @flash_sale = FlashSale.find(params[:id])
    @flash_sale.flash_sale_products.find_by(product_id: params[:product_id])&.destroy
    redirect_to edit_admin_flash_sale_path(@flash_sale)
  end

  private

  def flash_sale_params
    params.require(:flash_sale).permit(:name, :start_time, :end_time, :discount_percent, :active)
  end
end
