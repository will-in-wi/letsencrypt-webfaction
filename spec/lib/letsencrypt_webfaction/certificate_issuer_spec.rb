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
    let(:client) do
      challenge = instance_double('Acme::Client::Resources::Challenges::HTTP01', request_verification: true)
      authorization = instance_double('Acme::Client::Resources::Authorization', http01: challenge, verify_status: 'valid')
      allow(challenge).to receive(:authorization).and_return(authorization)
      cert = instance_double('::Acme::Client::Certificate', to_pem: 'CERT', chain_to_pem: 'CHAIN')
      allow(cert).to receive_message_chain(:request, :private_key, :to_pem) { 'PRIVATE KEY' }
      instance_double('Acme::Client', authorize: authorization, new_certificate: cert)
    end
    let(:issuer) { described_class.new(certificate: cert_config, api_credentials: api_credentials, client: client) }

    describe '#call' do
      subject { issuer.call }

      it 'validates and installs' do
        expect { subject }.to output(/Your new certificate is now created and installed/).to_stdout
      end
    end
  end
end
