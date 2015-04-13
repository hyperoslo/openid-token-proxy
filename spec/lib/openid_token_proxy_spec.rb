require 'spec_helper'

RSpec.describe OpenIDTokenProxy do
  describe '::client' do
    it 'returns global client' do
      client = described_class.client
      expect(client).to eq described_class.client
      expect(client).to be_a OpenIDTokenProxy::Client
    end
  end

  describe '::config' do
    it 'returns global configuration' do
      config = described_class.config
      expect(config).to eq described_class.config
      expect(config).to be_a OpenIDTokenProxy::Config
    end
  end

  describe '::configure' do
    it 'yields configuration' do
      expect do |probe|
        described_class.configure &probe
      end.to yield_with_args OpenIDTokenProxy.config
    end
  end

  describe '::configure_temporarily' do
    it 'yields temporary configuration' do
      original = OpenIDTokenProxy.config
      described_class.configure_temporarily do |config|
        expect(OpenIDTokenProxy.config).to eq config
        expect(config).not_to eq original
      end
      expect(OpenIDTokenProxy.config).to eq original
    end
  end
end
