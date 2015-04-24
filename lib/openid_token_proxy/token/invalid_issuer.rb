module OpenIDTokenProxy
  class Token

    # Raised when a token's issuer did not match
    class InvalidIssuer < Error
      def initialize
        super 'Token was issued by an unexpected issuer.'
      end
    end

  end
end
