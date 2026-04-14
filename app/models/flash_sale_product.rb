class FlashSaleProduct < ApplicationRecord
  belongs_to :flash_sale
  belongs_to :product

  validates :product_id, uniqueness: { scope: :flash_sale_id }

  def sold_out?
    max_quantity && sold_count >= max_quantity
  end
end
