# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_api_user!

      private

      def authenticate_api_user!
        token = request.headers["Authorization"]&.split(" ")&.last
        @current_api_user = User.find_by(id: decode_token(token)) if token
        return if @current_api_user

        render_api_error(
          code: "unauthorized",
          message: "Unauthorized",
          status: :unauthorized
        )
      end

      def current_api_user
        @current_api_user
      end

      def decode_token(token)
        return nil if token.blank?

        # Cache decoded user IDs for 5 minutes to avoid repeated verifier operations
        Rails.cache.fetch("api_token/#{Digest::SHA256.hexdigest(token)}", expires_in: 5.minutes) do
          verify_signed_token(token)
        end
      end

      def verify_signed_token(token)
        payload = User.api_token_verifier.verify(token, purpose: "api_auth")
        user_id = payload.is_a?(Hash) ? (payload[:user_id] || payload["user_id"]) : nil
        user_id.to_i if user_id.to_i.positive?
      rescue ActiveSupport::MessageVerifier::InvalidSignature, ArgumentError
        nil
      end

      def render_api_error(code:, message:, status:, details: nil)
        payload = {
          error: {
            code: code,
            message: message
          }
        }
        payload[:error][:details] = details if details.present?
        render json: payload, status: status
      end

      def pagination_params(default_limit: 20, max_limit: 50)
        raw_limit = params.fetch(:limit, default_limit).to_i
        raw_offset = params.fetch(:offset, 0).to_i

        {
          limit: [ raw_limit, 1 ].max.clamp(1, max_limit),
          offset: [ raw_offset, 0 ].max
        }
      end

      def pagination_meta(total:, limit:, offset:)
        current_page = (offset / limit) + 1
        total_pages = (total.to_f / limit).ceil
        {
          pagination: {
            total: total,
            limit: limit,
            offset: offset,
            current_page: current_page,
            total_pages: total_pages
          }
        }
      end
    end
  end
end
