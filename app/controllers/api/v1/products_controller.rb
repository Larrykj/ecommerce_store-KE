# frozen_string_literal: true

module Api
  module V1
    class ProductsController < BaseController
      skip_before_action :authenticate_api_user!, only: [ :index, :show ]

      # Cache version bumped when product data changes (set by Product model callbacks)
      PRODUCTS_CACHE_VERSION_KEY = "api/v1/products/cache_version".freeze

      def index
        cache_version = Rails.cache.fetch(PRODUCTS_CACHE_VERSION_KEY) { "v1" }
        cache_key = "api/v1/products/index/#{params[:category_id]}-#{params[:search]}-#{params[:limit]}-#{params[:offset]}-#{cache_version}"

        json_data = Rails.cache.fetch(cache_key, expires_in: 12.hours) do
          products = Product.kept
          products = products.where(category_id: params[:category_id]) if params[:category_id].present?
          products = products.search_by_text(params[:search]) if params[:search].present?
          products = products.includes(:variants, :category).with_attached_image.order(created_at: :desc)
                             .limit([ (params[:limit] || 20).to_i, 50 ].min)
                             .offset([ (params[:offset] || 0).to_i, 0 ].max)

          {
            products: products.map { |p| serialize_product(p) },
            total: Product.kept.count
          }
        end

        render json: json_data
      end

      def show
        cache_version = Rails.cache.fetch(PRODUCTS_CACHE_VERSION_KEY) { "v1" }
        cache_key = "api/v1/products/show/#{params[:id]}-#{cache_version}"

        json_data = Rails.cache.fetch(cache_key, expires_in: 12.hours) do
          product = Product.kept.includes(variants: [], category: []).with_attached_image.find(params[:id])
          { product: serialize_product(product, full: true) }
        end

        render json: json_data
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Product not found" }, status: :not_found
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
          variants = product.variants.loaded? ? product.variants.to_a : product.variants.to_a

          data.merge!(
            description: product.description,
            variants: variants.map { |v|
              { id: v.id, name: v.name, sku: v.sku, price: v.price.to_f, quantity: v.quantity }
            },
            reviews: product.reviews.includes(:user).order(created_at: :desc).limit(10).map { |r|
              { id: r.id, rating: r.rating, title: r.title, content: r.content, user: r.user&.name, created_at: r.created_at }
            }
          )
        end

        data
      end
    end
  end
end
