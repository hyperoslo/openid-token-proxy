module OpenIDTokenProxy
  module Concerns
    module CallbackController
      extend ActiveSupport::Concern

      def handle
        unless code = params[:code]
          render text: "Required parameter 'code' missing.", status: :bad_request
          return
        end

        begin
          token = OpenIDTokenProxy.client.retrieve_token!(auth_code: code)
        rescue OpenIDTokenProxy::Client::AuthCodeError => error
          render text: "Could not exchange authorization code: #{error.message}.",
                 status: :bad_request
          return
        end

        config = OpenIDTokenProxy.config
        uri = instance_exec token, &config.token_acquirement_hook
        redirect_to uri || main_app.root_url unless performed?
      end
    end
  end
end
