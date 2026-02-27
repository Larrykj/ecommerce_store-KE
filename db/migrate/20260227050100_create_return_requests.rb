class CreateReturnRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :return_requests do |t|
      t.references :order, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :reason, null: false
      t.text :description
      t.string :status, default: "pending" # pending, approved, rejected, completed
      t.text :admin_notes

      t.timestamps
    end

    add_index :return_requests, :status
  end
end
