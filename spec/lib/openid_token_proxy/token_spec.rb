require 'spec_helper'

RSpec.describe OpenIDTokenProxy::Token do
  subject { described_class.new 'access token' }

  describe '#to_s' do
    it 'returns access token' do
      expect(subject.to_s).to eq 'access token'
    end
  end

  describe '::decode!' do
    let(:keys) { [double] }

    context 'when token is omitted' do
      it 'raises' do
        expect do
          described_class.decode! '', keys
        end.to raise_error OpenIDTokenProxy::Token::TokenRequired
      end
    end

    context 'when token is malformed' do
      it 'raises' do
        expect do
          described_class.decode! 'malformed token', keys
        end.to raise_error OpenIDTokenProxy::Token::TokenMalformed
      end
    end

    context 'when token is well-formed' do
      context 'with invalid signature or missing public keys' do
        it 'raises' do
          expect do
            described_class.decode! 'well-formed token', []
          end.to raise_error OpenIDTokenProxy::Token::TokenInvalid
        end
      end

      context 'with valid signature' do
        it 'returns token with an identity token' do
          object = double(raw_attributes: {
            iss: double,
            sub: double,
            aud: double,
            exp: double,
            iat: double
          })
          expect(OpenIDConnect::RequestObject).to receive(:decode).and_return object
          token = described_class.decode! 'valid token', keys
          expect(token).to be_an OpenIDTokenProxy::Token
          expect(token.access_token).to eq 'valid token'
          expect(token.id_token).to be_an OpenIDConnect::ResponseObject::IdToken
        end
      end
    end
  end
end
