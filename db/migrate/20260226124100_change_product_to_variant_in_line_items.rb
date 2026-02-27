class ChangeProductToVariantInLineItems < ActiveRecord::Migration[8.1]
  def up
    CartItem.delete_all
    OrderItem.delete_all

    remove_reference :cart_items, :product, null: false, foreign_key: true
    add_reference :cart_items, :variant, null: false, foreign_key: true

    remove_reference :order_items, :product, null: false, foreign_key: true
    add_reference :order_items, :variant, null: false, foreign_key: true
  end

  def down
    remove_reference :cart_items, :variant, null: false, foreign_key: true
    add_reference :cart_items, :product, null: false, foreign_key: true

    remove_reference :order_items, :variant, null: false, foreign_key: true
    add_reference :order_items, :product, null: false, foreign_key: true
  end
end
