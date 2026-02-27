class CreateVariants < ActiveRecord::Migration[8.1]
  def change
    create_table :variants do |t|
      t.references :product, null: false, foreign_key: true
      t.string :sku
      t.string :name
      t.decimal :price
      t.integer :quantity
      t.integer :lock_version

      t.timestamps
    end
    add_index :variants, :sku, unique: true
  end
end
