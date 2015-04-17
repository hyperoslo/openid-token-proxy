require 'spec_helper'

require 'securerandom'

RSpec.describe OpenIDTokenProxy::Client do
  subject { described_class.new config }
  let(:config) do
    OpenIDTokenProxy::Config.new do |config|
      config.client_id = 'id'
      config.issuer = 'https://example.com'
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

  describe '#token_via_auth_code!' do
    let(:client) { double('authorization_code=' => nil) }

    before do
      expect(subject).to receive(:new_client).and_return client
    end

    context 'when auth code could not be exchanged' do
      it 'raises' do
        error = Rack::OAuth2::Client::Error.new 400, {}
        expect(client).to receive(:access_token!).and_raise error
        expect do
          subject.token_via_auth_code! 'malformed auth code'
        end.to raise_error OpenIDTokenProxy::Client::AuthCodeError
      end
    end

    context 'when auth code is valid' do
      it 'returns token instance' do
        access_token = double(
          access_token: 'access token',
          id_token: 'id token',
          refresh_token: 'refresh token'
        )
        expect(client).to receive(:access_token!).and_return access_token
        token = subject.token_via_auth_code! 'valid auth code'
        expect(token.access_token).to eq 'access token'
        expect(token.id_token).to eq 'id token'
        expect(token.refresh_token).to eq 'refresh token'
      end
    end
  end
end
