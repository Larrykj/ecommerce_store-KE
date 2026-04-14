class BundleItem < ApplicationRecord
  belongs_to :bundle, class_name: "ProductBundle"
  belongs_to :product

  validates :product_id, uniqueness: { scope: :bundle_id }
end
