class CreatePromoCodes < ActiveRecord::Migration[8.1]
  def change
    create_table :promo_codes do |t|
      t.string :code
      t.string :discount_type
      t.decimal :discount_value
      t.decimal :min_order_amount
      t.integer :max_uses
      t.integer :current_uses
      t.datetime :expires_at
      t.boolean :active
      t.string :description

      t.timestamps
    end
    add_index :promo_codes, :code, unique: true
    add_index :promo_codes, :current_uses
  end
end
