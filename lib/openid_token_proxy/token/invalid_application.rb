module OpenIDTokenProxy
  class Token

    # Raised when a token's application did not match
    class InvalidApplication < Error
      def initialize
        super 'Token is not intended for this application.'
      end
    end

  end
end
