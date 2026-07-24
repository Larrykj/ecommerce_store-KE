require "application_system_test_case"

class CartFreezeTest < ApplicationSystemTestCase
  setup do
    @product = Product.create!(name: "Test Product", description: "This is a long enough description", price: 10.0, category: Category.create!(name: "Test"))
    @product.variants.create!(name: "Default Variant", price: 10.0, quantity: 10, sku: "TEST-1")
  end

  test "add to cart does not freeze" do
    visit root_path
    visit products_path
    assert_selector ".add-cart-btn"
    click_button class: "add-cart-btn", match: :first

    # After click, it should show a toast
    assert_selector ".toast-notification.success", text: "Product added to cart successfully.", wait: 5

    # The button should NOT be disabled
    assert_selector ".add-cart-btn"
    button = first(".add-cart-btn")
    assert_not button.disabled?

    # We should be able to click it again
    click_button class: "add-cart-btn", match: :first
    assert_selector ".toast-notification.success", text: "Product quantity updated in cart.", wait: 5
  end
end
