require 'openid_token_proxy/client'
require 'openid_token_proxy/config'
require 'openid_token_proxy/version'

module OpenIDTokenProxy
  def self.configure
    yield Config.instance
  end
end
