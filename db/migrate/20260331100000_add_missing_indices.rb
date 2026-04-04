class AddMissingIndices < ActiveRecord::Migration[8.1]
  def change
    # Add indices to variants table for better query performance
    add_index :variants, :quantity unless index_exists?(:variants, :quantity)
    add_index :variants, :updated_at unless index_exists?(:variants, :updated_at)
    add_index :variants, [ :product_id, :quantity ] unless index_exists?(:variants, [ :product_id, :quantity ])
  end
end
