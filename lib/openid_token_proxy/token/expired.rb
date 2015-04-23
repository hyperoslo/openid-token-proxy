module OpenIDTokenProxy
  class Token

    # Raised when a token has expired
    class Expired < Error
      def initialize
        super 'Token has expired.'
      end
    end

  end
end
