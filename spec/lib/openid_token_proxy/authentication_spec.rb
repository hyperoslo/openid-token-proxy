require 'spec_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    include OpenIDTokenProxy::Authentication

    require_valid_token

    def index
      raise OpenIDTokenProxy::Error if params[:error]
      render nothing: true, status: :ok
    end
  end

  context 'when token proxy errors are encountered' do
    it 'results in 401 UNAUTHORIZED with authorization URI' do
      get :index, error: true
      expect(response).to have_http_status :unauthorized
      expect(response.headers).to have_key 'X-Authorization-URI'
    end
  end

  context 'when no token proxy errors are encountered' do
    it 'executes actions normally' do
      token = double(validate!: true)
      expect(controller).to receive(:current_token).and_return token
      get :index
      expect(response).to have_http_status :ok
    end
  end

  describe '#current_token' do
    it 'returns current valid token' do
      token = double
      expect(OpenIDTokenProxy::Token).to receive(:decode!).and_return token
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
