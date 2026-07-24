class AddMissingPerformanceIndexes < ActiveRecord::Migration[8.1]
  def change
    add_index :flash_sales, [:active, :start_time, :end_time], name: 'index_flash_sales_on_active_and_times'
    add_index :orders, [:user_id, :status]
    add_index :orders, [:user_id, :created_at]
    add_index :categories, :name
  end
end
