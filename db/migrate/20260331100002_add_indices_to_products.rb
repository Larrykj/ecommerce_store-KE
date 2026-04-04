class AddIndicesToProducts < ActiveRecord::Migration[8.1]
  def change
    # Add indices to products table for better filtering
    add_index :products, :category_id unless index_exists?(:products, :category_id)
    add_index :products, :created_at unless index_exists?(:products, :created_at)
    add_index :products, :price unless index_exists?(:products, :price)
  end
end
