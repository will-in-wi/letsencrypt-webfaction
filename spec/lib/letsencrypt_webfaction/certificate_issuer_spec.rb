require 'letsencrypt_webfaction/certificate_issuer'

module LetsencryptWebfaction
  RSpec.describe CertificateIssuer do
    let(:cert_config) { {} }
    let(:options) { {} }
    let(:client) { {} }
    let(:issuer) { described_class.new(certificate: cert_config, options: options, client: client) }

    describe '#call' do
      subject { issuer.call }
    end
  end
end
