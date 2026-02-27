class AddShippingAndTaxFieldsToOrders < ActiveRecord::Migration[8.1]
  def change
    add_reference :orders, :shipping_method, null: true, foreign_key: true
    add_column :orders, :shipping_cost, :decimal
    add_column :orders, :tax_amount, :decimal
    add_column :orders, :tax_rate, :decimal
  end
end
