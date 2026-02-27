class AddPromoCodeToCart < ActiveRecord::Migration[8.1]
  def change
    add_column :carts, :promo_code_id, :integer
  end
end
