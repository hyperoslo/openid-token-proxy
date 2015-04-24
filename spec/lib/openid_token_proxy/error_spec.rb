require 'spec_helper'

RSpec.describe OpenIDTokenProxy::Error do
  subject { described_class.new 'error message' }

  describe '#to_json' do
    it 'includes error message' do
      expect(subject.to_json).to eq(error: 'error message')
    end
  end
end
