require 'openid_connect'
require 'singleton'

module OpenIDTokenProxy
  class Config
    include Singleton

    attr_accessor :client_id, :client_secret, :issuer, :resource
    attr_accessor :authorization_endpoint, :token_endpoint, :userinfo_endpoint

    def initialize
      @client_id = ENV['OPENID_CLIENT_ID']
      @client_secret = ENV['OPENID_CLIENT_SECRET']
      @issuer = ENV['OPENID_ISSUER']
      @resource = ENV['OPENID_RESOURCE']

      @authorization_endpoint = ENV['OPENID_AUTHORIZATION_ENDPOINT']
      @token_endpoint = ENV['OPENID_TOKEN_ENDPOINT']
      @userinfo_endpoint = ENV['OPENID_USERINFO_ENDPOINT']
    end

    def provider_config
      @provider_config ||= begin
        OpenIDConnect::Discovery::Provider::Config.discover! issuer
      end
    end

    def authorization_endpoint
      @authorization_endpoint || provider_config.authorization_endpoint
    end

    def token_endpoint
      @token_endpoint || provider_config.token_endpoint
    end

    def userinfo_endpoint
      @userinfo_endpoint || provider_config.userinfo_endpoint
    end

    def public_keys
      # TODO: Allow configuration of public keys manually
      provider_config.public_keys
    end
  end
end
