module OpenIDTokenProxy
  class Token

    # Raised when a token's audience did not match
    class InvalidAudience < Error
      def initialize(audience)
        super "Token was issued for an unexpected audience: #{audience}."
      end
    end

  end
end
