module OpenIDTokenProxy
  class Token

    # Raised when a token could not be decoded
    class Malformed < Error
      def initialize(message)
        super "Token is malformed: #{message}."
      end
    end

  end
end
