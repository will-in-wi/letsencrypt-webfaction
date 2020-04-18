# frozen_string_literal: true

require 'letsencrypt_webfaction/certificate_issuer'
require 'letsencrypt_webfaction/webfaction_api_credentials'
require 'letsencrypt_webfaction/options/certificate'

module LetsencryptWebfaction
  RSpec.describe CertificateIssuer do
    let(:cert_config) { Options::Certificate.new('domains' => 'test.example.com') }
    let(:api_credentials) do
      instance_double('LetsencryptWebfaction::WebfactionApiCredentials').tap do |creds|
        allow(creds).to receive(:call).and_return({}, nil)
      end
    end
    let(:order) do
      instance_double(Acme::Client::Resources::Order, authorizations: [], finalize: true, certificate: 'CERTIFICATE', reload: nil).tap do |o|
        allow(o).to receive(:status).and_return('processing', 'processed')
      end
    end
    let(:client) { instance_double('Acme::Client', new_order: order) }
    let(:issuer) { described_class.new(certificate: cert_config, api_credentials: api_credentials, client: client) }

    before :each do
      # Speed up sleep
      allow_any_instance_of(Object).to receive(:sleep)
    end

    describe '#call' do
      subject { issuer.call }

      it 'validates and installs' do
        expect { subject }.to output(/Your new certificate is now created and installed/).to_stdout
      end
    end
  end
end
