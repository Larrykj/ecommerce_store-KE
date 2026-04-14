# frozen_string_literal: true

module Api
  module V1
    class ProductsController < BaseController
      skip_before_action :authenticate_api_user!, only: [ :index, :show ]

      # Cache version bumped when product data changes (set by Product model callbacks)
      PRODUCTS_CACHE_VERSION_KEY = "api/v1/products/cache_version".freeze

      def index
        pagination = pagination_params
        limit = pagination[:limit]
        offset = pagination[:offset]
        cache_version = Rails.cache.fetch(PRODUCTS_CACHE_VERSION_KEY) { "v1" }
        cache_key = "api/v1/products/index/#{params[:category_id]}-#{params[:search]}-#{limit}-#{offset}-#{cache_version}"

        json_data = Rails.cache.fetch(cache_key, expires_in: 12.hours) do
          scoped_products = Product.kept
          scoped_products = scoped_products.where(category_id: params[:category_id]) if params[:category_id].present?
          scoped_products = scoped_products.search_by_text(params[:search]) if params[:search].present?

          products = scoped_products.includes(:variants, :category).with_attached_image.order(created_at: :desc)
                                   .limit(limit)
                                   .offset(offset)
          total = scoped_products.count

          {
            products: products.map { |p| serialize_product(p) },
            total: total,
            meta: pagination_meta(total: total, limit: limit, offset: offset)
          }
        end

        render json: json_data
      end

      def show
        cache_version = Rails.cache.fetch(PRODUCTS_CACHE_VERSION_KEY) { "v1" }
        cache_key = "api/v1/products/show/#{params[:id]}-#{cache_version}"

        json_data = Rails.cache.fetch(cache_key, expires_in: 12.hours) do
          product = Product.kept.includes(variants: [], category: [], reviews: :user).with_attached_image.find(params[:id])
          { product: serialize_product(product, full: true) }
        end

        render json: json_data
      rescue ActiveRecord::RecordNotFound
        render_api_error(
          code: "product_not_found",
          message: "Product not found",
          status: :not_found
        )
      end

      private

      def serialize_product(product, full: false)
        data = {
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

        if full
          data.merge!(
            description: product.description,
            variants: product.variants.map { |v|
              { id: v.id, name: v.name, sku: v.sku, price: v.price.to_f, quantity: v.quantity }
            },
            reviews: product.reviews.sort_by(&:created_at).reverse.first(10).map { |r|
              { id: r.id, rating: r.rating, title: r.title, content: r.content, user: r.user&.name, created_at: r.created_at }
            }
          )
        end

        data
      end
    end
  end
end
