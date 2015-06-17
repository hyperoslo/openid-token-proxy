module OpenIDTokenProxy
  class Client
    attr_accessor :config

    def initialize(config = OpenIDTokenProxy.config)
      @config = config
    end

    def authorization_uri
      config.authorization_uri || new_client.authorization_uri(
        domain_hint: config.domain_hint,
        prompt: config.prompt,
        resource: config.resource
      )
    end

    # Raised when auth code could not be exchanged
    class AuthCodeError < Error; end

    # Raised when refresh token could not be exchanged
    class RefreshTokenError < Error; end

    # Raised when token could not be retrieved for given credentials
    class CredentialsError < Error; end

    # Retrieves a token for given auth code, refresh token or username/password
    def retrieve_token!(params)
      client = new_client

      if auth_code = params.delete(:auth_code)
        client.authorization_code = auth_code
      end

      if refresh_token = params.delete(:refresh_token)
        client.refresh_token = refresh_token
      end

      if username = params.delete(:username)
        client.resource_owner_credentials = [
          username,
          params.delete(:password)
        ]
      end

      response = client.access_token!(:query_string, params)
      token = Token.decode!(response.access_token)
      token.refresh_token = response.refresh_token
      token
    rescue Rack::OAuth2::Client::Error => e
      raise AuthCodeError.new(e.message) if auth_code
      raise RefreshTokenError.new(e.message) if refresh_token
      raise CredentialsError.new(e.message) if username
    end

    def new_client
      OpenIDConnect::Client.new(
        identifier:             config.client_id,
        secret:                 config.client_secret,
        authorization_endpoint: config.authorization_endpoint,
        token_endpoint:         config.token_endpoint,
        userinfo_endpoint:      config.userinfo_endpoint,
        redirect_uri:           config.redirect_uri
      )
    end
  end
end
