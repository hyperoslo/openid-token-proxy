module OpenIDTokenProxy
  class Error < StandardError
    def to_json
      { error: message }
    end
  end
end
