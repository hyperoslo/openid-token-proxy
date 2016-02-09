require 'spec_helper'

RSpec.describe OpenIDTokenProxy::CallbackController, type: :controller do
  routes { OpenIDTokenProxy::Engine.routes }
  let(:access_token) { 'access token' }
  let(:auth_code) { 'authorization code' }
  let(:client) { OpenIDTokenProxy.client }
  let(:token) { OpenIDTokenProxy::Token.new 'token' }

  context 'when authorization code is missing' do
    it 'results in 400 BAD REQUEST with error message' do
      get :handle
      expect(response.body).to eq "Required parameter 'code' missing."
      expect(response).to have_http_status :bad_request
    end
  end

  context 'when authorization code is given' do
    context 'when authorization code could not be exchanged' do
      it 'results in 400 BAD REQUEST with error message' do
        error = OpenIDTokenProxy::Client::AuthCodeError.new 'msg'
        expect(client).to receive(:retrieve_token!).with(
          auth_code: auth_code
        ).and_raise error
        get :handle, code: auth_code
        expect(response.body).to eq 'Could not exchange authorization code: msg.'
        expect(response).to have_http_status :bad_request
      end
    end

    context 'when authorization code could be exchanged' do
      before do
        expect(client).to receive(:retrieve_token!).and_return token
      end

      context 'with no-op token acquirement hook' do
        it 'redirects to root' do
          OpenIDTokenProxy.configure_temporarily do |config|
            block = double('block')
            config.token_acquirement_hook = proc { |token|
              block.run(token)
            }
            expect(block).to receive(:run).with(instance_of(OpenIDTokenProxy::Token))
            get :handle, code: auth_code
            expect(response).to redirect_to controller.main_app.root_url
          end
        end
      end

      context 'when returning URI from token acquirement hook' do
        it 'redirects to returned URI' do
          OpenIDTokenProxy.configure_temporarily do |config|
            uri = '/#token'
            config.token_acquirement_hook = proc { |token, error|
              uri
            }
            get :handle, code: auth_code
            expect(response).to redirect_to uri
          end
        end
      end

      context 'when performing an action within token acquirement hook' do
        it 'takes no additional action' do
          OpenIDTokenProxy.configure_temporarily do |config|
            config.token_acquirement_hook = proc { |token, error|
              render text: 'Custom action'
            }
            get :handle, code: auth_code
            expect(response.body).to eq 'Custom action'
          end
        end
      end
    end
  end
end
