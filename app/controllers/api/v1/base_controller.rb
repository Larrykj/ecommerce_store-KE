# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_api_user!

      private

      def authenticate_api_user!
        token = request.headers["Authorization"]&.split(" ")&.last
        @current_api_user = User.find_by(id: decode_token(token)) if token
        render json: { error: "Unauthorized" }, status: :unauthorized unless @current_api_user
      end

      def current_api_user
        @current_api_user
      end

      def decode_token(token)
        return nil if token.blank?

        # Cache decoded user IDs for 5 minutes to avoid repeated verifier operations
        Rails.cache.fetch("api_token/#{Digest::SHA256.hexdigest(token)}", expires_in: 5.minutes) do
          user_id = verify_signed_token(token)
          return user_id if user_id

          verify_legacy_token(token)
        end
      end

      def verify_signed_token(token)
        payload = User.api_token_verifier.verify(token, purpose: "api_auth")
        user_id = payload.is_a?(Hash) ? (payload[:user_id] || payload["user_id"]) : nil
        user_id.to_i if user_id.to_i.positive?
      rescue ActiveSupport::MessageVerifier::InvalidSignature, ArgumentError
        nil
      end

      def verify_legacy_token(token)
        legacy_id = Base64.decode64(token).to_i
        legacy_id if legacy_id.positive?
      rescue StandardError
        nil
      end
    end
  end
end
