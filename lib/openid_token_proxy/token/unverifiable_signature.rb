module OpenIDTokenProxy
  class Token

    # Raised when a token's signature could not be verified
    class UnverifiableSignature < Error
      def initialize
        super 'Token signature could not be verified.'
      end
    end

  end
end
