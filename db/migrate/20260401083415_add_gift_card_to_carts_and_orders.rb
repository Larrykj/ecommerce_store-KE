class AddGiftCardToCartsAndOrders < ActiveRecord::Migration[8.1]
  def change
    add_reference :carts, :gift_card, null: true, foreign_key: true
    add_reference :orders, :gift_card, null: true, foreign_key: true
  end
end
