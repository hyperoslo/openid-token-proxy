require 'spec_helper'

RSpec.describe OpenIDTokenProxy::Token do
  subject { described_class.new 'access token', id_token }

  let(:audience) { 'audience' }
  let(:client_id) { 'client ID' }
  let(:issuer) { 'issuer' }
  let(:expiry_time) { 2.hours.from_now }

  let(:id_token) {
    double(
      exp: expiry_time,
      aud: audience,
      iss: issuer,
      raw_attributes: {
        'appid' => client_id
      }
    )
  }

  describe '#to_s' do
    it 'returns access token' do
      expect(subject.to_s).to eq 'access token'
    end
  end

  describe '#[]' do
    it 'retrieves identity attributes' do
      expect(subject['appid']).to eq client_id
    end
  end

  describe '#validate!' do
    context 'when token has expired' do
      let(:expiry_time) { 2.hours.ago }

      it 'raises' do
        expect do
          subject.validate!
        end.to raise_error OpenIDTokenProxy::Token::Expired
      end
    end

    context 'when audience differs' do
      it 'raises' do
        expect do
          subject.validate! audience: 'expected audience'
        end.to raise_error OpenIDTokenProxy::Token::InvalidAudience
      end
    end

    context 'when issuer differs' do
      it 'raises' do
        expect do
          subject.validate! issuer: 'expected issuer'
        end.to raise_error OpenIDTokenProxy::Token::InvalidIssuer
      end
    end

    context 'when all is well' do
      it 'returns true' do
        assertions = {
          audience: audience,
          client_id: client_id,
          issuer: issuer
        }
        expect(subject.validate! assertions).to be_truthy
      end
    end
  end

  describe '#valid?' do
    context 'when token is invalid' do
      it 'returns false' do
        allow(subject).to receive(:validate!).and_raise OpenIDTokenProxy::Token::Expired
        expect(subject).not_to be_valid
      end
    end

    context 'when token is valid' do
      it 'returns true' do
        allow(subject).to receive(:validate!).and_return true
        expect(subject).to be_valid
      end
    end
  end

  describe '#expiry_time' do
    it 'returns expiry time' do
      expect(subject.expiry_time.to_i).to eq expiry_time.to_i
    end

    it 'is in UTC' do
      expect(subject.expiry_time.zone).to eq 'UTC'
    end
  end

  describe '#expired?' do
    context 'when token has expired' do
      let(:expiry_time) { 2.hours.ago }
      it { should be_expired }
    end

    context 'when token has not yet expired' do
      it { should_not be_expired }
    end
  end

  describe '::decode!' do
    let(:keys) { [double] }

    context 'when token is omitted' do
      it 'raises' do
        expect do
          described_class.decode! '', keys
        end.to raise_error OpenIDTokenProxy::Token::Required
      end
    end

    context 'when token is malformed' do
      it 'raises' do
        expect do
          described_class.decode! 'malformed token', keys
        end.to raise_error OpenIDTokenProxy::Token::Malformed
      end
    end

    context 'when token is well-formed' do
      context 'with invalid signature' do
        before do
          allow(OpenIDConnect::RequestObject).to receive(:decode).and_raise JSON::JWT::VerificationFailed
        end

        it 'raises' do
          expect do
            described_class.decode! 'well-formed token', keys
          end.to raise_error OpenIDTokenProxy::Token::UnverifiableSignature
        end

        it 'cleans up SSL error queue' do
          errors = double(clear: true)
          allow(OpenSSL).to receive(:errors).and_return errors
          expect do
            described_class.decode! 'well-formed token', keys
          end.to raise_error OpenIDTokenProxy::Token::UnverifiableSignature
          expect(errors).to have_received(:clear)
        end
      end

      context 'with missing public keys' do
        it 'raises' do
          expect do
            described_class.decode! 'well-formed token', []
          end.to raise_error OpenIDTokenProxy::Token::UnverifiableSignature
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
