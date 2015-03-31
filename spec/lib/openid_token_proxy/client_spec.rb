require 'spec_helper'

require 'securerandom'

RSpec.describe OpenIDTokenProxy::Client do
  subject { described_class.new config }
  let(:config) do
    OpenIDTokenProxy::Config.new do |config|
      config.client_id = 'id'
      config.authorization_endpoint = 'https://example.com/auth'
    end
  end

  describe '#config' do
    it 'defaults to Config.instance' do
      client = described_class.new
      expect(client.config).to eq OpenIDTokenProxy::Config.instance
    end

    it 'may be given explicitly' do
      expect(subject.config).to eq config
    end
  end

  describe '#authorization_uri' do
    it 'may be explicitly set through environment' do
      stub_env('OPENID_AUTHORIZATION_URI', 'from env')
      expect(subject.authorization_uri).to eq 'from env'
    end

    context 'when not explicitly set' do
      let(:expected_auth_uri) {
        'https://example.com/auth?client_id=id&response_type=code&scope=openid'
      }

      it 'builds OpenID authorization URI' do
        expect(subject.authorization_uri).to eq expected_auth_uri
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

  describe '::instance' do
    it 'returns global client' do
      instance = described_class.instance
      expect(instance).to eq described_class.instance
      expect(instance).to be_a described_class
    end
  end
end
