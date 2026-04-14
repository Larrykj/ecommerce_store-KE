# frozen_string_literal: true

module Api
  module V1
    class CategoriesController < BaseController
      skip_before_action :authenticate_api_user!

      CATEGORIES_CACHE_KEY = "api/v1/categories/index".freeze

      def index
        json_data = Rails.cache.fetch(CATEGORIES_CACHE_KEY, expires_in: 1.hour) do
          categories = Category.kept
                               .order(:name)
          product_counts = Product.kept.group(:category_id).count
          total = categories.size

          {
            categories: categories.map { |c| serialize_category(c, product_counts[c.id].to_i) },
            total: total,
            meta: pagination_meta(total: total, limit: total.nonzero? || 1, offset: 0)
          }
        end

        render json: json_data
      end

      def show
        pagination = pagination_params
        limit = pagination[:limit]
        offset = pagination[:offset]
        cache_key = "api/v1/categories/show/#{params[:id]}-#{limit}-#{offset}"

        json_data = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
          category = Category.kept.find(params[:id])
          products = category.products.kept
                             .includes(:category, :variants)
                             .with_attached_image
                             .order(created_at: :desc)
                             .limit(limit)
                             .offset(offset)

          total_products = category.products.kept.count

          {
            category: serialize_category(category, total_products),
            products: products.map { |p| serialize_product(p) },
            total: total_products,
            meta: pagination_meta(total: total_products, limit: limit, offset: offset)
          }
        end

        render json: json_data
      rescue ActiveRecord::RecordNotFound
        render_api_error(
          code: "category_not_found",
          message: "Category not found",
          status: :not_found
        )
      end

      private

      def serialize_category(category, count = nil)
        {
          id: category.id,
          name: category.name,
          description: category.description,
          products_count: count.nil? ? category.products.kept.count : count
        }
      end

      def serialize_product(product)
        {
          id: product.id,
          name: product.name,
          price: product.price.to_f,
          category: product.category&.name,
          in_stock: product.in_stock?,
          rating: product.average_rating.to_f,
          review_count: product.reviews_count.to_i,
          image_url: product.image.attached? ? url_for(product.image) : nil,
          created_at: product.created_at
        }
      end
    end
  end
end
