require 'active_support/concern'

module OpenIDTokenProxy
  class Token
    module Authentication
      extend ActiveSupport::Concern

      included do
        rescue_from OpenIDTokenProxy::Error, with: :require_authorization

        helper_method :current_token, :raw_token
      end

      module ClassMethods
        def require_valid_token(*args)
          before_action :require_valid_token, *args
        end
      end

      def set_authentication_url!
        uri = OpenIDTokenProxy.client.authorization_uri
        response.headers['X-Authentication-URL'] = uri
      end

      def require_authorization(exception)
        set_authentication_url!
        render json: exception.to_json, status: :unauthorized
      end

      def require_valid_token
        config = OpenIDTokenProxy.config
        current_token.validate! audience: config.resource,
                                client_id: config.client_id
      end

      def current_token
        @current_token ||= OpenIDTokenProxy::Token.decode!(raw_token)
      end

      def raw_token
        token = params[:token]
        return token if token

        authorization = request.headers['Authorization']
        if authorization
          token = authorization[/Bearer (.+)/, 1]
          return token if token
        end

        request.headers['X-Token']
      end
    end
  end
end
