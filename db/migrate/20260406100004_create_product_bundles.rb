class CreateProductBundles < ActiveRecord::Migration[7.1]
  def change
    create_table :product_bundles do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.decimal :price
      t.decimal :original_price
      t.decimal :discount_percent
      t.boolean :active, default: true
      t.integer :max_quantity
      t.timestamps
    end
    add_index :product_bundles, :slug, unique: true

    create_table :bundle_items do |t|
      t.references :bundle, null: false, foreign_key: { to_table: :product_bundles }
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, default: 1
      t.timestamps
    end
    add_index :bundle_items, [ :bundle_id, :product_id ], unique: true
  end
end
