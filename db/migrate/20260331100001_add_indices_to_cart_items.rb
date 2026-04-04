class AddIndicesToCartItems < ActiveRecord::Migration[8.1]
  def change
    # Add indices to cart_items table for better query performance
    add_index :cart_items, :cart_id unless index_exists?(:cart_items, :cart_id)
    add_index :cart_items, :variant_id unless index_exists?(:cart_items, :variant_id)
    add_index :cart_items, [ :cart_id, :variant_id ], unique: true unless index_exists?(:cart_items, [ :cart_id, :variant_id ])
  end
end
