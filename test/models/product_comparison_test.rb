require "test_helper"

class ProductComparisonTest < ActiveSupport::TestCase
  setup do
    @comparison = product_comparisons(:one)
  end

  test "should be valid with valid attributes" do
    assert @comparison.valid?
  end

  test "belongs to product" do
    assert_kind_of Product, @comparison.product
  end

  test "max 4 products in comparison" do
    user = users(:two)
    # Create 4 products for comparison
    4.times do |i|
      p = Product.create!(name: "Compare Prod #{i}", description: "A comparison product for testing", price: 100)
      ProductComparison.create!(user: user, product: p, session_id: "session_#{user.id}")
    end
    extra = Product.create!(name: "Compare Prod Extra", description: "Should fail validation test", price: 100)
    comp = ProductComparison.new(user: user, product: extra, session_id: "session_#{user.id}")
    assert_not comp.valid?
    assert comp.errors[:base].any?
  end
end
