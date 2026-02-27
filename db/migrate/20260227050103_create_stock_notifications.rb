class CreateStockNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :stock_notifications do |t|
      t.references :product, null: false, foreign_key: true
      t.references :user, foreign_key: true, null: true
      t.string :email, null: false
      t.boolean :notified, default: false

      t.timestamps
    end

    add_index :stock_notifications, [ :product_id, :email ], unique: true
  end
end
