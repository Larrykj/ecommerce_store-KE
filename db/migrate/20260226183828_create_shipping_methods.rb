class CreateShippingMethods < ActiveRecord::Migration[8.1]
  def change
    create_table :shipping_methods do |t|
      t.string :name
      t.decimal :base_rate
      t.integer :estimated_days
      t.boolean :active

      t.timestamps
    end
  end
end
