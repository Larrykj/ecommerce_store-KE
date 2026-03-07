require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  setup do
    @category = categories(:one)
  end

  test "should be valid with valid attributes" do
    assert @category.valid?
  end

  test "should require name" do
    @category.name = nil
    assert_not @category.valid?
  end

  test "name must have minimum 2 characters" do
    @category.name = "A"
    assert_not @category.valid?
  end

  test "name must have maximum 50 characters" do
    @category.name = "A" * 51
    assert_not @category.valid?
  end

  test "has many products" do
    assert_respond_to @category, :products
  end

  test "has many reviews through products" do
    assert_respond_to @category, :reviews
  end

  test "average_rating returns numeric value" do
    assert_kind_of Numeric, @category.average_rating
  end

  test "total_reviews_count returns integer" do
    assert_kind_of Integer, @category.total_reviews_count
  end

  test "advanced_search returns results" do
    results = Category.advanced_search({})
    assert_respond_to results, :each
  end
end
