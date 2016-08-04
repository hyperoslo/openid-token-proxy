require 'spec_helper'

RSpec.describe OpenIDTokenProxy::Config do
  subject { described_class.new }
  let(:with_valid_issuer) {
    subject.issuer = 'https://login.windows.net/common'
    subject
  }

  before do
    stub_request(:get, "https://login.windows.net/common/.well-known/openid-configuration")
      .to_return(body: fixture('openid-configuration.json'))
    stub_request(:get, "https://login.windows.net/common/discovery/keys")
      .to_return(body: fixture('keys.json'))
    stub_request(:get, "https://example.com/.well-known/openid-configuration")
      .to_return(status: 404)
  end

  describe '#initialize' do
    it 'yields configuration to given block' do
      config = described_class.new do |config|
        config.client_id = 'from-block'
      end
      expect(config.client_id).to eq 'from-block'
    end
  end

  describe '#client_id' do
    it 'obtains its default from environment' do
      stub_env('OPENID_CLIENT_ID', 'from env')
      expect(subject.client_id).to eq 'from env'
    end

    it 'may be set explicitly' do
      subject.client_id = 'overridden'
      expect(subject.client_id).to eq 'overridden'
    end
  end

  describe '#client_secret' do
    it 'obtains its default from environment' do
      stub_env('OPENID_CLIENT_SECRET', 'from env')
      expect(subject.client_secret).to eq 'from env'
    end

    it 'may be set explicitly' do
      subject.client_secret = 'overridden'
      expect(subject.client_secret).to eq 'overridden'
    end
  end

  describe '#issuer' do
    it 'obtains its default from environment' do
      stub_env('OPENID_ISSUER', 'from env')
      expect(subject.issuer).to eq 'from env'
    end

    it 'may be overriden' do
      subject.issuer = 'overridden'
      expect(subject.issuer).to eq 'overridden'
    end
  end

  describe '#domain_hint' do
    it 'obtains its default from environment' do
      stub_env('OPENID_DOMAIN_HINT', 'from env')
      expect(subject.domain_hint).to eq 'from env'
    end

    it 'may be overriden' do
      subject.domain_hint = 'overridden'
      expect(subject.domain_hint).to eq 'overridden'
    end
  end

  describe '#prompt' do
    it 'obtains its default from environment' do
      stub_env('OPENID_PROMPT', 'from env')
      expect(subject.prompt).to eq 'from env'
    end

    it 'may be overriden' do
      subject.prompt = 'overridden'
      expect(subject.prompt).to eq 'overridden'
    end
  end

  describe '#redirect_uri' do
    it 'obtains its default from environment' do
      stub_env('OPENID_REDIRECT_URI', 'from env')
      expect(subject.redirect_uri).to eq 'from env'
    end

    it 'may be set explicitly' do
      subject.redirect_uri = 'overridden'
      expect(subject.redirect_uri).to eq 'overridden'
    end
  end

  describe '#resource' do
    it 'obtains its default from environment' do
      stub_env('OPENID_RESOURCE', 'from env')
      expect(subject.resource).to eq 'from env'
    end

    it 'may be set explicitly' do
      subject.resource = 'overridden'
      expect(subject.resource).to eq 'overridden'
    end
  end

  describe '#audiences' do
    context 'obtaining its default from environment' do
      it 'supports a single audience' do
        stub_env('OPENID_AUDIENCES', 'foo')
        expect(subject.audiences).to eq ['foo']
      end

      it 'supports multiple audiences' do
        stub_env('OPENID_AUDIENCES', 'foo,bar')
        expect(subject.audiences).to eq ['foo', 'bar']
      end
    end

    it 'may be set explicitly' do
      subject.audiences = ['overridden']
      expect(subject.audiences).to eq ['overridden']
    end

    it 'may be obtained implicitly from resource' do
      subject.resource = 'resource'
      expect(subject.audiences).to eq ['resource']
    end
  end

  describe '#authorization_uri' do
    it 'obtains its default from environment' do
      stub_env('OPENID_AUTHORIZATION_URI', 'from env')
      expect(subject.authorization_uri).to eq 'from env'
    end

    it 'may be set explicitly' do
      subject.authorization_uri = 'overridden'
      expect(subject.authorization_uri).to eq 'overridden'
    end
  end

  describe '#provider_config' do
    context 'when valid issuer' do
      it 'loads provider configuration' do
        expect do
          with_valid_issuer.provider_config
        end.not_to raise_error
      end
    end

    context 'when issuer omitted' do
      it 'raises' do
        stub_env('OPENID_ISSUER')
        expect do
          subject.provider_config
        end.to raise_error URI::InvalidURIError
      end
    end

    context 'when invalid issuer' do
      it 'raises' do
        subject.issuer = 'https://example.com'
        expect do
          subject.provider_config
        end.to raise_error OpenIDConnect::Discovery::DiscoveryFailed
      end
    end
  end

  describe '#authorization_endpoint' do
    it 'obtains its default from environment' do
      stub_env('OPENID_AUTHORIZATION_ENDPOINT', 'from env')
      expect(subject.authorization_endpoint).to eq 'from env'
    end

    it 'may be set explicitly' do
      subject.authorization_endpoint = 'overridden'
      expect(subject.authorization_endpoint).to eq 'overridden'
    end

    context 'when not set' do
      it 'defaults to endpoint from provider config' do
        stub_env('OPENID_AUTHORIZATION_ENDPOINT')
        ep = with_valid_issuer.authorization_endpoint
        expect(ep).to eq 'https://login.windows.net/common/oauth2/authorize'
      end
    end
  end

  describe '#token_endpoint' do
    it 'obtains its default from environment' do
      stub_env('OPENID_TOKEN_ENDPOINT', 'from env')
      expect(subject.token_endpoint).to eq 'from env'
    end

    it 'may be set explicitly' do
      subject.token_endpoint = 'overridden'
      expect(subject.token_endpoint).to eq 'overridden'
    end

    context 'when not set' do
      it 'defaults to endpoint from provider config' do
        stub_env('OPENID_TOKEN_ENDPOINT')
        ep = with_valid_issuer.token_endpoint
        expect(ep).to eq 'https://login.windows.net/common/oauth2/token'
      end
    end
  end

  describe '#userinfo_endpoint' do
    it 'obtains its default from environment' do
      stub_env('OPENID_USERINFO_ENDPOINT', 'from env')
      expect(subject.userinfo_endpoint).to eq 'from env'
    end

    it 'may be set explicitly' do
      subject.userinfo_endpoint = 'overridden'
      expect(subject.userinfo_endpoint).to eq 'overridden'
    end

    context 'when not set' do
      it 'defaults to endpoint from provider config' do
        stub_env('OPENID_USERINFO_ENDPOINT')
        ep = with_valid_issuer.userinfo_endpoint
        expect(ep).to eq 'https://login.windows.net/common/openid/userinfo'
      end
    end
  end

  describe '#end_session_endpoint' do
    it 'obtains its default from environment' do
      stub_env('OPENID_END_SESSION_ENDPOINT', 'from env')
      expect(subject.end_session_endpoint).to eq 'from env'
    end

    it 'may be set explicitly' do
      subject.end_session_endpoint = 'overridden'
      expect(subject.end_session_endpoint).to eq 'overridden'
    end

    context 'when not set' do
      it 'defaults to endpoint from provider config' do
        stub_env('OPENID_END_SESSION_ENDPOINT')
        ep = with_valid_issuer.end_session_endpoint
        expect(ep).to eq 'https://login.windows.net/common/oauth2/logout'
      end
    end
  end

  describe '#public_keys' do
    it 'may be set explicitly' do
      subject.public_keys = []
      expect(subject.public_keys).to eq []
    end

    context 'when not set' do
      it 'retrieves public keys from provider' do
        keys = with_valid_issuer.public_keys
        expect(keys.first).to be_an OpenSSL::PKey::PKey
      end
    end
  end
end
