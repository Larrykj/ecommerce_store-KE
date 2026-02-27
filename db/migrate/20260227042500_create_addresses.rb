class CreateAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :label, default: "Home"
      t.string :name, null: false
      t.string :phone
      t.string :address_line_1, null: false
      t.string :address_line_2
      t.string :city, null: false
      t.string :state
      t.string :postal_code
      t.string :country, default: "Kenya"
      t.boolean :default, default: false

      t.timestamps
    end

    add_index :addresses, [:user_id, :default]
  end
end
