require 'openid_token_proxy/token/expired'
require 'openid_token_proxy/token/invalid_audience'
require 'openid_token_proxy/token/invalid_issuer'
require 'openid_token_proxy/token/malformed'
require 'openid_token_proxy/token/required'
require 'openid_token_proxy/token/unverifiable_signature'

module OpenIDTokenProxy
  class Token
    attr_accessor :access_token, :id_token, :refresh_token

    def initialize(access_token, id_token = nil, refresh_token = nil)
      @access_token = access_token
      if id_token.is_a? Hash
        id_token = OpenIDConnect::ResponseObject::IdToken.new(id_token)
      end
      @id_token = id_token
      @refresh_token = refresh_token
    end

    def to_s
      @access_token
    end

    # Retrieves data from identity attributes
    def [](key)
      id_token.raw_attributes[key]
    end

    # Validates this token's expiration state, application, audience and issuer
    def validate!(assertions = {})
      raise Expired if expired?

      # TODO: Nonce validation

      if assertions[:audience]
        audiences = Array(id_token.aud)
        raise InvalidAudience unless audiences.include? assertions[:audience]
      end

      if assertions[:issuer]
        issuer = id_token.iss
        raise InvalidIssuer unless issuer == assertions[:issuer]
      end

      true
    end

    # Whether this token is valid
    def valid?(assertions = {})
      validate!(assertions)
    rescue OpenIDTokenProxy::Error
      false
    end

    def expiry_time
      Time.at(id_token.exp.to_i).utc
    end

    def expired?
      id_token.exp.to_i <= Time.now.to_i
    end

    # Decodes given access token and validates its signature by public key(s)
    # Use :skip_verification as second argument to skip signature validation
    def self.decode!(access_token, keys = OpenIDTokenProxy.config.public_keys)
      raise Required if access_token.blank?

      Array(keys).each do |key|
        begin
          object = OpenIDConnect::RequestObject.decode(access_token, key)
        rescue JSON::JWT::InvalidFormat => e
          raise Malformed.new(e.message)
        rescue JSON::JWT::VerificationFailed
          # Iterate through remaining public keys (if any)
          # Raises UnverifiableSignature if none applied (see below)

          # A failure in Certificate#verify leaves messages on the error queue,
          # which can lead to errors in SSL communication down the road.
          # See: https://bugs.ruby-lang.org/issues/7215
          OpenSSL.errors.clear
        else
          return Token.new(access_token, object.raw_attributes)
        end
      end

      raise UnverifiableSignature
    end
  end
end
