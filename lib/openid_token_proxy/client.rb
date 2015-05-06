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

    # Retrieves a token for given authorization code or refresh token
    def retrieve_token!(params)
      client = new_client
      client.authorization_code = params[:auth_code] if params[:auth_code]
      client.refresh_token = params[:refresh_token] if params[:refresh_token]
      response = client.access_token!(:query_string)
      token = Token.decode!(response.access_token)
      token.refresh_token = response.refresh_token
      token
    rescue Rack::OAuth2::Client::Error => e
      raise AuthCodeError.new(e.message) if params[:auth_code]
      raise RefreshTokenError.new(e.message) if params[:refresh_token]
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
