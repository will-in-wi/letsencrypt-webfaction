require 'letsencrypt_webfaction/certificate_writer'

RSpec.describe LetsencryptWebfaction::CertificateWriter do
  let(:cert_dir) { 'spec/tmp/' }
  let(:domain) { 'www.example.com' }

  after :each do
    # Clean out the test folder.
    FileUtils.rm_rf Dir.glob("#{cert_dir}/*")
  end

  it 'works' do
    private_key = double 'private_key', to_pem: 'PRIVATE_KEY'
    request = double 'request', private_key: private_key
    certificate = double 'certificate', request: request
    allow(certificate).to receive(:to_pem).and_return('CERTIFICATE')
    allow(certificate).to receive(:chain_to_pem).and_return('CHAIN CERTIFICATE')
    allow(certificate).to receive(:fullchain_to_pem).and_return('FULL CHAIN CERTIFICATE')

    cert_writer = LetsencryptWebfaction::CertificateWriter.new cert_dir, domain, certificate

    cert_writer.write!

    files = Dir.glob("#{cert_dir}www.example.com/*/*")
    expect(files.size).to eq 4
    files.sort! # Make it indexable
    expect(File.basename(files[0])).to eq 'cert.pem'
    expect(File.basename(files[1])).to eq 'chain.pem'
    expect(File.basename(files[2])).to eq 'fullchain.pem'
    expect(File.basename(files[3])).to eq 'privkey.pem'
  end
end
