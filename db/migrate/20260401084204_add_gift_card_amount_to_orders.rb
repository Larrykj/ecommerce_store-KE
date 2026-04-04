class AddGiftCardAmountToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :gift_card_amount, :decimal
  end
end
