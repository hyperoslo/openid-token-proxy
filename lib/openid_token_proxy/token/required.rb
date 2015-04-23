module OpenIDTokenProxy
  class Token

    # Raised when a token was not provided
    class Required < Error
      def initialize
        super 'Token must be provided.'
      end
    end

  end
end
