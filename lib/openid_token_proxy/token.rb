module OpenIDTokenProxy
  class Token
    attr_accessor :access_token, :id_token, :refresh_token

    def initialize(access_token, id_token = nil, refresh_token = nil)
      @access_token = access_token
      @id_token = id_token
      @refresh_token = refresh_token
    end

    def to_s
      @access_token
    end
  end
end
