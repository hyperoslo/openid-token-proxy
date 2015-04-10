require 'spec_helper'

RSpec.describe OpenIDTokenProxy do
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
