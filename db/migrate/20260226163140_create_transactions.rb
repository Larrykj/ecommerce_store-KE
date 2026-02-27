class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions do |t|
      t.references :order, null: false, foreign_key: true
      t.string :stripe_payment_intent_id
      t.string :stripe_checkout_session_id
      t.decimal :amount
      t.string :currency
      t.string :status
      t.string :payment_method
      t.text :error_message
      t.decimal :refund_amount
      t.datetime :refunded_at

      t.timestamps
    end
  end
end
