class RemoveQuantityFromProducts < ActiveRecord::Migration[8.1]
  def change
    remove_column :products, :quantity, :integer
  end
end
