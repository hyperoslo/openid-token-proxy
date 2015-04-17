require File.expand_path('../../config/initializers/inflections', __FILE__)

require 'openid_connect'

require 'openid_token_proxy/error'

require 'openid_token_proxy/client'
require 'openid_token_proxy/config'
require 'openid_token_proxy/engine'
require 'openid_token_proxy/token'
require 'openid_token_proxy/version'

module OpenIDTokenProxy
  class << self
    def client
      @client ||= Client.new
    end

    def config
      @config ||= Config.new
    end

    def configure
      yield config
    end

    # Sets and yields a new global config for the duration of the given block
    def configure_temporarily
      original = config
      @config = original.dup
      yield @config
    ensure
      @config = original
    end
  end
end
