require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "should require name" do
    user = User.new(email: "new@example.com", password: "password12345", name: nil)
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "should require email" do
    user = User.new(name: "Test", password: "password12345", email: nil)
    assert_not user.valid?
  end

  test "should require unique email" do
    user = User.new(name: "Dup", email: @user.email, password: "password12345")
    assert_not user.valid?
  end

  test "password should be at least 12 characters" do
    user = User.new(name: "Test", email: "new@example.com", password: "short")
    assert_not user.valid?
  end

  # ====== Associations ======
  test "has many orders" do
    assert_respond_to @user, :orders
  end

  test "has many reviews" do
    assert_respond_to @user, :reviews
  end

  test "has many wishlist_items" do
    assert_respond_to @user, :wishlist_items
  end

  test "has many addresses" do
    assert_respond_to @user, :addresses
  end

  test "has many return_requests" do
    assert_respond_to @user, :return_requests
  end

  test "has many stock_notifications" do
    assert_respond_to @user, :stock_notifications
  end

  test "has many product_comparisons" do
    assert_respond_to @user, :product_comparisons
  end

  # ====== Devise ======
  test "active_for_authentication? returns true for undiscarded user" do
    assert @user.active_for_authentication?
  end

  # ====== Recommended Products ======
  test "recommended_products returns products" do
    results = @user.recommended_products
    assert_respond_to results, :each
  end

  # ====== Soft Delete ======
  test "destroy soft deletes the user" do
    @user.destroy
    assert @user.reload.discarded?
  end
end
