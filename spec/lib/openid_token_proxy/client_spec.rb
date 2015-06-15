require 'spec_helper'

require 'securerandom'

RSpec.describe OpenIDTokenProxy::Client do
  subject { described_class.new config }
  let(:config) do
    OpenIDTokenProxy::Config.new do |config|
      config.client_id = 'id'
      config.issuer = 'https://example.com'
      config.resource = nil
      config.domain_hint = nil
      config.prompt = nil
      config.authorization_endpoint = 'https://example.com/auth'
      config.token_endpoint = 'https://example.com/token'
      config.userinfo_endpoint = 'https://example.com/users'
    end
  end

  describe '#config' do
    it 'defaults to OpenIDTokenProxy.config' do
      client = described_class.new
      expect(client.config).to eq OpenIDTokenProxy.config
    end

    it 'may be given explicitly' do
      expect(subject.config).to eq config
    end
  end

  describe '#authorization_uri' do
    it 'may be explicitly set through configuration' do
      config.authorization_uri = 'overridden'
      expect(subject.authorization_uri).to eq 'overridden'
    end

    context 'when not explicitly set' do
      let(:expected_auth_uri) {
        'https://example.com/auth?client_id=id&response_type=code&scope=openid'
      }

      it 'builds OpenID authorization URI' do
        expect(subject.authorization_uri).to eq expected_auth_uri
      end

      context 'when domain hint given' do
        it 'includes domain hint' do
          hint = SecureRandom.hex
          config.domain_hint = hint
          expect(subject.authorization_uri).to include "domain_hint=#{hint}"
        end
      end

      context 'when prompt given' do
        it 'includes prompt' do
          prompt = SecureRandom.hex
          config.prompt = prompt
          expect(subject.authorization_uri).to include "prompt=#{prompt}"
        end
      end

      context 'when resource given' do
        it 'includes resource' do
          resource = SecureRandom.hex
          config.resource = resource
          expect(subject.authorization_uri).to include "resource=#{resource}"
        end
      end

      context 'when redirect_uri given' do
        it 'includes redirect_uri' do
          uri = SecureRandom.hex
          config.redirect_uri = uri
          expect(subject.authorization_uri).to include "redirect_uri=#{uri}"
        end
      end
    end
  end

  describe '#retrieve_token!' do
    let(:client) {
      double(
        'authorization_code=' => nil,
        'refresh_token=' => nil,
        'resource_owner_credentials=' => nil
      )
    }
    let(:access_token) { 'access token' }
    let(:id_token) { 'id token' }
    let(:refresh_token) { 'refresh token' }
    let(:response) {
      double(
        access_token: access_token,
        id_token: id_token,
        refresh_token: refresh_token
      )
    }
    let(:token) {
      OpenIDTokenProxy::Token.new(access_token, id_token)
    }

    before do
      expect(subject).to receive(:new_client).and_return client
      allow(OpenIDTokenProxy::Token).to receive(:decode!).and_return token
    end

    context 'using auth code' do
      context 'when auth code could not be exchanged' do
        it 'raises' do
          error = Rack::OAuth2::Client::Error.new 400, {}
          expect(client).to receive(:access_token!).and_raise error
          expect do
            subject.retrieve_token! auth_code: 'malformed auth code'
          end.to raise_error OpenIDTokenProxy::Client::AuthCodeError
        end
      end

      context 'when auth code is valid' do
        it 'returns token instance' do
          expect(client).to receive(:access_token!).with(
            :query_string, {}
          ).and_return response
          token = subject.retrieve_token! auth_code: 'valid auth code'
          expect(token.access_token).to eq access_token
          expect(token.id_token).to eq id_token
          expect(token.refresh_token).to eq refresh_token
        end
      end
    end

    context 'using refresh token' do
      context 'when refresh token could not be exchanged' do
        it 'raises' do
          error = Rack::OAuth2::Client::Error.new 400, {}
          expect(client).to receive(:access_token!).and_raise error
          expect do
            subject.retrieve_token! refresh_token: 'malformed refresh token'
          end.to raise_error OpenIDTokenProxy::Client::RefreshTokenError
        end
      end

      context 'when refresh token is valid' do
        it 'returns token instance' do
          expect(client).to receive(:access_token!).with(
            :query_string, {}
          ).and_return response
          token = subject.retrieve_token! refresh_token: 'valid refresh token'
          expect(token.access_token).to eq access_token
          expect(token.id_token).to eq id_token
          expect(token.refresh_token).to eq refresh_token
        end
      end
    end

    context 'using username and password' do
      context 'when credentials are invalid' do
        it 'raises' do
          error = Rack::OAuth2::Client::Error.new 400, {}
          expect(client).to receive(:access_token!).and_raise error
          expect do
            token = subject.retrieve_token! username: 'foo', password: 'bar'
          end.to raise_error OpenIDTokenProxy::Client::CredentialsError
        end
      end

      context 'when credentials are valid' do
        it 'returns token instance' do
          expect(client).to receive(:access_token!).with(
            :query_string, {}
          ).and_return response
          token = subject.retrieve_token! username: 'foo', password: 'bar'
          expect(token.access_token).to eq access_token
          expect(token.id_token).to eq id_token
          expect(token.refresh_token).to eq refresh_token
        end
      end
    end

    context 'when given options' do
      it 'passes these through' do
        expect(client).to receive(:access_token!).with(
          :query_string, resource: 'x'
        ).and_return response
        subject.retrieve_token! auth_code: 'valid auth code', resource: 'x'
      end
    end
  end
end
