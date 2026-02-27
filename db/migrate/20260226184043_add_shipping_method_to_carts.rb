class AddShippingMethodToCarts < ActiveRecord::Migration[8.1]
  def change
    add_reference :carts, :shipping_method, null: true, foreign_key: true
  end
end
