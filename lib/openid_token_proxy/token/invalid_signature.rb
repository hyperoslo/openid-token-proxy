module OpenIDTokenProxy
  class Token

    # Raised when a token's signature could not be validated
    class InvalidSignature < Error
      def initialize
        super 'Token signature could not be validated.'
      end
    end

  end
end
