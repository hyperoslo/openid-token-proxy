require 'openid_connect'

module OpenIDTokenProxy
  class Client
    attr_reader :config

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
    class AuthCodeError < StandardError; end

    # Retrieves a token for given authorization code
    def token_via_auth_code!(auth_code)
      client = new_client
      client.authorization_code = auth_code
      response = client.access_token!(:query_string)
      Token.new(response.access_token, response.id_token, response.refresh_token)
    rescue Rack::OAuth2::Client::Error => e
      raise AuthCodeError.new(e.message)
    end

    # Raised when a token was not provided
    class TokenRequired < StandardError; end

    # Raised when a token could not be decoded
    class TokenMalformed < StandardError; end

    # Raised when a token's signature could not be validated
    class TokenInvalid < StandardError; end

    # Decodes given access token and validates its signature
    def decode_token!(access_token)
      raise TokenRequired if access_token.blank?

      begin
        config.public_keys.each do |key|
          begin
            object = OpenIDConnect::RequestObject.decode(access_token, key)
          rescue JSON::JWT::VerificationFailed
            # Iterate through remaining public keys (if any)
            # Raises TokenInvalid if none applied (see below)
          else
            id_token = OpenIDConnect::ResponseObject::IdToken.new(object.raw_attributes)
            token = Token.new(access_token)
            token.id_token = id_token
            return token
          end
        end
      rescue JSON::JWT::InvalidFormat => e
        raise TokenMalformed.new(e.message)
      end

      raise TokenInvalid
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
