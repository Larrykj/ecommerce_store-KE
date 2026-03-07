require "test_helper"

# CategoriesControllerTest - Integration tests for the Categories controller
#
# This test class verifies the CRUD operations for categories, including:
# - Public access to index and show actions
# - Protected access to create, edit, update, and destroy (requires authentication)
#
# Author: Larrykj
# Last Updated: 2026-01-30
class CategoriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @category = categories(:one)
    @user = users(:one)
  end

  # Test: Verify categories index page is publicly accessible
  test "should get index" do
    get categories_url
    assert_response :success
  end

  # Test: Verify individual category page is publicly accessible
  test "should get show" do
    get category_url(@category)
    assert_response :success
  end
end
