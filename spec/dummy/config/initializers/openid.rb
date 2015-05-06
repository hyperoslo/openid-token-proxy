OpenIDTokenProxy.configure do |config|
  config.token_acquirement_hook = proc { |token|
    main_app.root_url + "?token=#{token}&refresh_token=#{token.refresh_token}"
  }
end
