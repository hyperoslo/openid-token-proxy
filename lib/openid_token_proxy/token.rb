module OpenIDTokenProxy
  class Token
    attr_accessor :access_token, :refresh_token

    def initialize(access_token, refresh_token = nil)
      @access_token = access_token
      @refresh_token = refresh_token
    end
  end
end
