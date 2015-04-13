OpenIDTokenProxy.configure do |config|
  config.token_acquirement_hook = proc { |token, error|
    main_app.root_url + "?token=#{token}"
  }
end
