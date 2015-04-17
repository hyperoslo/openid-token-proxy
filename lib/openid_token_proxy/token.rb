module OpenIDTokenProxy
  class Token
    attr_accessor :access_token, :id_token, :refresh_token

    def initialize(access_token, id_token = nil, refresh_token = nil)
      @access_token = access_token
      @id_token = id_token
      @refresh_token = refresh_token
    end

    def to_s
      @access_token
    end

    # Raised when a token was not provided
    class TokenRequired < StandardError; end

    # Raised when a token could not be decoded
    class TokenMalformed < StandardError; end

    # Raised when a token's signature could not be validated
    class TokenInvalid < StandardError; end

    # Decodes given access token and validates its signature by public key(s)
    # Use :skip_verification as second argument to skip signature validation
    def self.decode!(access_token, keys = OpenIDTokenProxy.config.public_keys)
      raise TokenRequired if access_token.blank?

      Array(keys).each do |key|
        begin
          object = OpenIDConnect::RequestObject.decode(access_token, key)
        rescue JSON::JWT::InvalidFormat => e
          raise TokenMalformed.new(e.message)
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

      raise TokenInvalid
    end
  end
end
