module OpenIDTokenProxy
  class Token

    # Raised when a token's audience did not match
    class InvalidAudience < Error
      def initialize
        super 'Token was issued for an unexpected audience/resource.'
      end
    end

  end
end
