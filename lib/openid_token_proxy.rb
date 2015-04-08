require File.expand_path('../../config/initializers/inflections', __FILE__)

require 'openid_token_proxy/client'
require 'openid_token_proxy/config'
require 'openid_token_proxy/engine'
require 'openid_token_proxy/token'
require 'openid_token_proxy/version'

module OpenIDTokenProxy
  def self.configure
    yield Config.instance
  end
end
