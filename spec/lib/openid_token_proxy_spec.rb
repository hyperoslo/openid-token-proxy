require 'spec_helper'

RSpec.describe OpenIDTokenProxy do
  describe '::configure' do
    it 'yields configuration' do
      expect do |probe|
        described_class.configure &probe
      end.to yield_with_args OpenIDTokenProxy::Config.instance
    end
  end
end
