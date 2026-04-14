require "test_helper"

module Api
  module V1
    class ContractsTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:one)
      end

      test "orders index returns standardized unauthorized error envelope" do
        get "/api/v1/orders"

        assert_response :unauthorized
        body = response.parsed_body
        assert_equal "unauthorized", body.dig("error", "code")
        assert_equal "Unauthorized", body.dig("error", "message")
      end

      test "products index returns pagination meta" do
        get "/api/v1/products", params: { limit: 1, offset: 0 }

        assert_response :success
        body = response.parsed_body
        assert body["products"].is_a?(Array)
        assert body["total"].is_a?(Integer)
        assert_equal 1, body.dig("meta", "pagination", "limit")
        assert_equal 0, body.dig("meta", "pagination", "offset")
        assert_equal 1, body.dig("meta", "pagination", "current_page")
      end

      test "category show returns pagination meta for products list" do
        category = categories(:one)
        get "/api/v1/categories/#{category.id}", params: { limit: 1, offset: 0 }

        assert_response :success
        body = response.parsed_body
        assert body["products"].is_a?(Array)
        assert_equal 1, body.dig("meta", "pagination", "limit")
        assert_equal 0, body.dig("meta", "pagination", "offset")
      end

      test "orders index returns pagination meta when authorized" do
        get "/api/v1/orders", params: { limit: 1, offset: 0 }, headers: auth_headers(@user)

        assert_response :success
        body = response.parsed_body
        assert body["orders"].is_a?(Array)
        assert body["total"].is_a?(Integer)
        assert_equal 1, body.dig("meta", "pagination", "limit")
        assert_equal 0, body.dig("meta", "pagination", "offset")
      end

      private

      def auth_headers(user)
        { "Authorization" => "Bearer #{user.api_token}" }
      end
    end
  end
end
