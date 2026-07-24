class AddUserIdToCartsAndIndexes < ActiveRecord::Migration[8.1]
  def change
    add_column :carts, :user_id, :bigint
    add_index :carts, :user_id
    add_index :wishlist_items, [ :user_id, :product_id ], unique: true
  end
end
