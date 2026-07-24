class AddPromoMessageToPromoCodes < ActiveRecord::Migration[8.1]
  def change
    add_column :promo_codes, :promo_message, :string
    add_column :promo_codes, :display_on_storefront, :boolean
  end
end
