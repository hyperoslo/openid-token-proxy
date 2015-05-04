require 'spec_helper'

RSpec.describe OpenIDTokenProxy::Token::Authentication, type: :controller do
  let(:authorization_uri) { 'https://id.hyper.no/authorize' }
  let(:token) { double(validate!: true) }

  before do
    allow(OpenIDTokenProxy::Token).to receive(:decode!).and_return token
  end

  controller(ApplicationController) do
    include OpenIDTokenProxy::Token::Authentication

    require_valid_token

    def index
      raise OpenIDTokenProxy::Error if params[:error]
      render nothing: true, status: :ok
    end
  end

  context 'when token proxy errors are encountered' do
    it 'results in 401 UNAUTHORIZED with authentication URI' do
      OpenIDTokenProxy.configure_temporarily do |config|
        config.authorization_uri = authorization_uri
        get :index, error: true
      end
      expect(response).to have_http_status :unauthorized
      expect(response.headers['X-Authentication-URL']).to eq authorization_uri
    end
  end

  context 'when no token proxy errors are encountered' do
    it 'executes actions normally' do
      get :index
      expect(response).to have_http_status :ok
    end
  end

  describe '#current_token' do
    it 'returns current valid token' do
      expect(controller.current_token).to eq token
    end
  end

  describe '#raw_token' do
    it 'may be provided as parameter' do
      get :index, token: 'raw token'
      expect(controller.raw_token).to eq 'raw token'
    end

    it 'may be provided through authorization header' do
      request.headers['Authorization'] = 'Bearer raw token'
      get :index
      expect(controller.raw_token).to eq 'raw token'
    end

    it 'may be provided through X-Token header' do
      request.headers['X-Token'] = 'raw token'
      get :index
      expect(controller.raw_token).to eq 'raw token'
    end
  end
end
