class AddPromoCodeIndexToCarts < ActiveRecord::Migration[8.1]
  def change
    add_index :carts, :promo_code_id
  end
end
