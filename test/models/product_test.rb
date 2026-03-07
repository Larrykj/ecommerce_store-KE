require "test_helper"

class ProductTest < ActiveSupport::TestCase
  setup do
    @product = products(:one)
    @category = categories(:one)
  end

  # ====== Validations ======
  test "should be valid with valid attributes" do
    assert @product.valid?
  end

  test "should require name" do
    @product.name = nil
    assert_not @product.valid?
    assert_includes @product.errors[:name], "can't be blank"
  end

  test "name should have minimum 3 characters" do
    @product.name = "ab"
    assert_not @product.valid?
  end

  test "name should have maximum 100 characters" do
    @product.name = "a" * 101
    assert_not @product.valid?
  end

  test "should require description" do
    @product.description = nil
    assert_not @product.valid?
  end

  test "description should have minimum 10 characters" do
    @product.description = "short"
    assert_not @product.valid?
  end

  test "should require price" do
    @product.price = nil
    assert_not @product.valid?
  end

  test "price should be greater than 0" do
    @product.price = 0
    assert_not @product.valid?
    @product.price = -5
    assert_not @product.valid?
  end

  # ====== Associations ======
  test "belongs to category" do
    assert_equal @category, @product.category
  end

  test "has many variants" do
    assert_respond_to @product, :variants
  end

  test "has many reviews" do
    assert_respond_to @product, :reviews
  end

  # ====== Instance Methods ======
  test "quantity returns total stock across variants" do
    assert_equal variants(:one).quantity, @product.quantity
  end

  test "in_stock? returns true when variants have stock" do
    assert @product.in_stock?
  end

  test "formatted_price returns KSh format" do
    assert_match(/KSh/, @product.formatted_price)
  end

  test "stock_status_label returns correct label" do
    assert_kind_of String, @product.stock_status_label
  end

  test "stock_status_class returns valid bootstrap class" do
    assert_includes %w[success warning danger], @product.stock_status_class
  end

  # ====== Rating Methods ======
  test "average_rating returns numeric value" do
    assert_kind_of Numeric, @product.average_rating
  end

  test "reviews_count returns integer" do
    assert_kind_of Integer, @product.reviews_count
  end

  test "rating_percentage returns integer between 0 and 100" do
    pct = @product.rating_percentage
    assert pct >= 0 && pct <= 100
  end

  test "rating_distribution returns hash with keys 1-5" do
    dist = @product.rating_distribution
    assert_equal [ 1, 2, 3, 4, 5 ], dist.keys.sort
  end

  test "reviewed_by? returns boolean" do
    user = users(:one)
    assert_includes [ true, false ], @product.reviewed_by?(user)
  end

  test "reviewed_by? returns false for nil user" do
    assert_equal false, @product.reviewed_by?(nil)
  end

  # ====== Search ======
  test "advanced_search returns products" do
    results = Product.advanced_search({})
    assert_kind_of ActiveRecord::Relation, results
  end

  test "price_stats returns min max avg" do
    stats = Product.price_stats
    assert stats[:min] >= 0
    assert stats[:max] >= stats[:min]
  end
end
