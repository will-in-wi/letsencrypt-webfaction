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
    let(:order) { instance_double(Acme::Client::Resources::Order, authorizations: [], finalize: true, status: 'processed', certificate: 'CERTIFICATE') }
    let(:client) { instance_double('Acme::Client', new_order: order) }
    let(:issuer) { described_class.new(certificate: cert_config, api_credentials: api_credentials, client: client) }

    describe '#call' do
      subject { issuer.call }

      it 'validates and installs' do
        expect { subject }.to output(/Your new certificate is now created and installed/).to_stdout
      end
    end
  end
end
