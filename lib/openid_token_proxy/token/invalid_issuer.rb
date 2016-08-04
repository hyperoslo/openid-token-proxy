module OpenIDTokenProxy
  class Token

    # Raised when a token's issuer did not match
    class InvalidIssuer < Error
      def initialize(issuer)
        super "Token was issued by an unexpected issuer: #{issuer}."
      end
    end

  end
end
