class CreateFlashSales < ActiveRecord::Migration[7.1]
  def change
    create_table :flash_sales do |t|
      t.string :name
      t.datetime :start_time
      t.datetime :end_time
      t.decimal :discount_percent
      t.boolean :active, default: true
      t.timestamps
    end

    create_table :flash_sale_products do |t|
      t.references :flash_sale, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :max_quantity
      t.integer :sold_count, default: 0
      t.decimal :special_price
      t.timestamps
    end
    add_index :flash_sale_products, [ :flash_sale_id, :product_id ], unique: true
  end
end
