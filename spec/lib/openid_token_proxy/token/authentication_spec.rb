require 'spec_helper'

RSpec.describe OpenIDTokenProxy::Token::Authentication, type: :controller do
  let(:authorization_uri) { 'https://id.hyper.no/authorize' }
  let(:access_token) { 'access token' }
  let(:expiry_time) { 2.hours.from_now }
  let(:id_token) {
    double(
      exp: expiry_time
    )
  }
  let(:token) { OpenIDTokenProxy::Token.new(access_token, id_token) }

  before do
    allow(token).to receive(:validate!).and_return true
    allow(OpenIDTokenProxy::Token).to receive(:decode!).and_return token
  end

  controller(ApplicationController) do
    include OpenIDTokenProxy::Token::Authentication

    require_valid_token

    def index
      render text: 'Authentication successful', status: :ok
    end
  end

  context 'when token proxy errors are encountered' do
    it 'results in 401 UNAUTHORIZED with authentication URI' do
      expect(token).to receive(:validate!).and_raise OpenIDTokenProxy::Error
      OpenIDTokenProxy.configure_temporarily do |config|
        config.authorization_uri = authorization_uri
        get :index
      end
      expect(response).to have_http_status :unauthorized
      expect(response.headers['X-Authentication-URL']).to eq authorization_uri
    end
  end

  context 'when no token proxy errors are encountered' do
    it 'executes actions normally' do
      get :index
      expect(response).to have_http_status :ok
      expect(response.body).to eq 'Authentication successful'
    end

    it 'exposes token expiry time through header' do
      get :index
      expect(response.headers['X-Token-Expiry-Time']).to eq expiry_time.iso8601
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
