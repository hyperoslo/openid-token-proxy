module OpenIDTokenProxy
  class Token
    module Refresh
      extend ActiveSupport::Concern

      included do
        include OpenIDTokenProxy::Token::Authentication

        helper_method :raw_refresh_token

        def require_valid_token
          super
        rescue OpenIDTokenProxy::Token::Expired
          raise unless raw_refresh_token.present?
          @current_token = OpenIDTokenProxy.client.retrieve_token!(
            refresh_token: raw_refresh_token
          )
          response.headers['X-Token'] = current_token.access_token
          response.headers['X-Refresh-Token'] = current_token.refresh_token

          instance_exec(
            current_token.access_token,
            &OpenIDTokenProxy.config.token_refreshment_hook
          )
        end
      end

      def raw_refresh_token
        params[:refresh_token] || request.headers['X-Refresh-Token']
      end
    end
  end
end
