module OpenIDTokenProxy
  class CallbackController < ApplicationController
    def handle
      unless code = params[:code]
        render nothing: true, status: :bad_request
        return
      end

      begin
        token = OpenIDTokenProxy.client.token_via_auth_code!(code)
      rescue OpenIDTokenProxy::Client::AuthCodeException => error
        # Rescued here and passed into the token acquirement hook below
      end

      config = OpenIDTokenProxy.config
      uri = instance_exec token, error, &config.token_acquirement_hook
      redirect_to uri || main_app.root_url unless performed?
    end
  end
end
