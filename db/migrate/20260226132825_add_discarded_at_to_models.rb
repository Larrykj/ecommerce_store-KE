class AddDiscardedAtToModels < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :discarded_at, :datetime
    add_index :users, :discarded_at

    add_column :products, :discarded_at, :datetime
    add_index :products, :discarded_at
  end
end
