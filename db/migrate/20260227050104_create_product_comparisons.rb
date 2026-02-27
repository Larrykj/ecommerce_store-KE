class CreateProductComparisons < ActiveRecord::Migration[8.1]
  def change
    create_table :product_comparisons do |t|
      t.references :user, foreign_key: true, null: true
      t.string :session_id
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end

    add_index :product_comparisons, [:user_id, :product_id], unique: true
    add_index :product_comparisons, [:session_id, :product_id], unique: true
  end
end
