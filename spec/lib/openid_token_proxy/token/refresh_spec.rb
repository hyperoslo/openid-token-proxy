require 'spec_helper'

RSpec.describe OpenIDTokenProxy::Token::Refresh, type: :controller do
  let(:authorization_uri) { 'https://id.hyper.no/authorize' }
  let(:refresh_token) { 'refresh token' }
  let(:token) {
    OpenIDTokenProxy::Token.new('expired access token', nil, refresh_token)
  }
  let(:refreshed_expiry_time) { 2.hours.from_now }
  let(:refreshed_id_token) {
    double(
      exp: refreshed_expiry_time
    )
  }
  let(:refreshed_token) {
    OpenIDTokenProxy::Token.new(
      'new access token',
      refreshed_id_token,
      'new refresh token'
    )
  }

  before do
    expect(token).to receive(:validate!).and_raise OpenIDTokenProxy::Token::Expired
    expect(OpenIDTokenProxy::Token).to receive(:decode!).and_return token
    allow(OpenIDTokenProxy.client).to receive(:retrieve_token!).with(
      refresh_token: refresh_token
    ).and_return refreshed_token
  end

  controller(ApplicationController) do
    include OpenIDTokenProxy::Token::Refresh

    require_valid_token

    def index
      render text: 'Refresh successful', status: :ok
    end
  end

  context 'when token has expired' do
    context 'when refresh token could not be exchanged' do
      it 'results in 401 UNAUTHORIZED with authentication URI' do
        error = OpenIDTokenProxy::Client::RefreshTokenError.new 'msg'
        expect(OpenIDTokenProxy.client).to receive(:retrieve_token!).with(
          refresh_token: refresh_token
        ).and_raise error
        OpenIDTokenProxy.configure_temporarily do |config|
          config.authorization_uri = authorization_uri
          get :index, refresh_token: refresh_token
        end
        expect(response).to have_http_status :unauthorized
        expect(response.headers['X-Authentication-URL']).to eq authorization_uri
        expect(response.headers).not_to include 'X-Token', 'X-Refresh-Token'
      end
    end

    context 'when token was refreshed successfully' do
      it 'executes actions normally returning new tokens as headers' do
        OpenIDTokenProxy.configure_temporarily do |config|
          block = double('block')
          config.token_refreshment_hook = proc { |token, error| block.run }
          expect(block).to receive(:run)
          get :index, refresh_token: refresh_token
          expect(response).to have_http_status :ok
          expect(response.body).to eq 'Refresh successful'
          expect(response.headers['X-Token']).to eq 'new access token'
          expect(response.headers['X-Refresh-Token']).to eq 'new refresh token'
          expect(response.headers['X-Token-Expiry-Time']).to eq refreshed_expiry_time.iso8601
        end
      end
    end
  end

  describe '#raw_refresh_token' do
    it 'may be provided as parameter' do
      get :index, refresh_token: refresh_token
      expect(controller.raw_refresh_token).to eq 'refresh token'
    end

    it 'may be provided through X-Refresh-Token header' do
      request.headers['X-Refresh-Token'] = refresh_token
      get :index
      expect(controller.raw_refresh_token).to eq 'refresh token'
    end
  end
end
