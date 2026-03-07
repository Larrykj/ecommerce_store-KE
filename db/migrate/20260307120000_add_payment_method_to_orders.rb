class AddPaymentMethodToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :payment_method, :string, default: "manual_confirmation", null: false unless column_exists?(:orders, :payment_method)
    add_column :orders, :notes, :text unless column_exists?(:orders, :notes)
    add_column :orders, :address_id, :bigint unless column_exists?(:orders, :address_id)
    add_foreign_key :orders, :addresses, if_not_exists: true
  end
end
