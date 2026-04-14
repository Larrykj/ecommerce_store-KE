class AddTierToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :current_tier_id, :integer
    add_index :users, :current_tier_id
  end
end
