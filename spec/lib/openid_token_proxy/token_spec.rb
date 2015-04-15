require 'spec_helper'

RSpec.describe OpenIDTokenProxy::Token do
  subject { described_class.new 'access token' }

  describe '#to_s' do
    it 'returns access token' do
      expect(subject.to_s).to eq 'access token'
    end
  end
end
