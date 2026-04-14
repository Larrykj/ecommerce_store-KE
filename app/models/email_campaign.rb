class EmailCampaign < ApplicationRecord
  enum :campaign_type, { welcome: "welcome", newsletter: "newsletter", abandoned_cart: "abandoned_cart", order_followup: "order_followup", flash_sale: "flash_sale" }, prefix: true

  scope :active, -> { where(active: true) }

  def send!
    update!(sent_at: Time.current)
  end
end
