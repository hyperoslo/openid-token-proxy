require 'spec_helper'

require 'securerandom'

RSpec.describe OpenIDTokenProxy::Client do
  subject { described_class.new config }
  let(:config) { OpenIDTokenProxy::Config.new }

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

    context 'when resource given' do
      it 'defaults to OpenID authorization URI' do
        authorization_uri = subject.authorization_uri
        expect(authorization_uri).not_to be_blank
        expect(authorization_uri).not_to include 'resource='
        expect(authorization_uri).not_to include 'redirect_uri='
      end
    end

    context 'when resource given' do
      it 'includes resource' do
        config.resource = id = SecureRandom.hex
        expect(subject.authorization_uri).to include "resource=#{id}"
      end
    end

    context 'when redirect_uri given' do
      it 'includes redirect_uri' do
        config.redirect_uri = id = SecureRandom.hex
        expect(subject.authorization_uri).to include "redirect_uri=#{id}"
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
