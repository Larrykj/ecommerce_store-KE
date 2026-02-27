class CreateGiftCards < ActiveRecord::Migration[8.1]
  def change
    create_table :gift_cards do |t|
      t.string :code, null: false
      t.decimal :initial_value, null: false, precision: 10, scale: 2
      t.decimal :balance, null: false, precision: 10, scale: 2
      t.references :purchased_by, foreign_key: { to_table: :users }, null: true
      t.references :redeemed_by, foreign_key: { to_table: :users }, null: true
      t.string :recipient_email
      t.string :status, default: "active" # active, redeemed, expired, disabled
      t.date :expires_at

      t.timestamps
    end

    add_index :gift_cards, :code, unique: true
    add_index :gift_cards, :status
  end
end
