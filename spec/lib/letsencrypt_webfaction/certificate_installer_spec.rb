require 'letsencrypt_webfaction/certificate_installer'
require 'letsencrypt_webfaction/webfaction_api_credentials'

RSpec.describe LetsencryptWebfaction::CertificateInstaller do
  let(:creds) { LetsencryptWebfaction::WebfactionApiCredentials.new username: 'myusername', password: 'mypassword', servername: 'myservername', api_server: 'https://wfserverapi.example.com/' }

  let(:certificate) do
    private_key = double 'private_key', to_pem: 'PRIVATE_KEY'
    request = double 'request', private_key: private_key
    certificate = double 'certificate', request: request
    allow(certificate).to receive(:to_pem).and_return('CERTIFICATE')
    allow(certificate).to receive(:chain_to_pem).and_return('CHAIN CERTIFICATE')
    allow(certificate).to receive(:fullchain_to_pem).and_return('FULL CHAIN CERTIFICATE')

    certificate
  end

  let(:cert_name) { 'test_auto_cert' }

  let(:cert_installer) { LetsencryptWebfaction::CertificateInstaller.new cert_name, certificate, creds }

  before :each do
    stub_request(:post, 'https://wfserverapi.example.com/')
      .with(body: "<?xml version=\"1.0\" ?><methodCall><methodName>login</methodName><params><param><value><string>myusername</string></value></param><param><value><string>mypassword</string></value></param><param><value><string>myservername</string></value></param><param><value><i4>2</i4></value></param></params></methodCall>\n")
      .to_return(status: 200, body: fixture('login_response.xml'))
    stub_request(:post, "https://wfserverapi.example.com/")
      .with(body: "<?xml version=\"1.0\" ?><methodCall><methodName>list_certificates</methodName><params><param><value><string>oz7e1xz9r0mf0wgue22hsj8tgkhqyo74</string></value></param></params></methodCall>\n")
      .to_return(status: 200, body: fixture('list_certificates_response.xml'))
  end

  context 'with existing certificate' do
    before :each do
      stub_request(:post, "https://wfserverapi.example.com/")
        .with(body: "<?xml version=\"1.0\" ?><methodCall><methodName>update_certificate</methodName><params><param><value><string>oz7e1xz9r0mf0wgue22hsj8tgkhqyo74</string></value></param><param><value><string>test_auto_cert</string></value></param><param><value><string>CERTIFICATE</string></value></param><param><value><string>PRIVATE_KEY</string></value></param><param><value><string>CHAIN CERTIFICATE</string></value></param></params></methodCall>\n")
        .to_return(status: 200, body: fixture('create_certificate_response.xml'))
    end

    it 'updates certificate' do
      cert_installer.install!

      expect(WebMock).to have_requested(:post, "https://wfserverapi.example.com/")
        .with(body: "<?xml version=\"1.0\" ?><methodCall><methodName>update_certificate</methodName><params><param><value><string>oz7e1xz9r0mf0wgue22hsj8tgkhqyo74</string></value></param><param><value><string>test_auto_cert</string></value></param><param><value><string>CERTIFICATE</string></value></param><param><value><string>PRIVATE_KEY</string></value></param><param><value><string>CHAIN CERTIFICATE</string></value></param></params></methodCall>\n")
    end
  end

  context 'without existing certificate' do
    before :each do
      stub_request(:post, "https://wfserverapi.example.com/")
        .with(body: "<?xml version=\"1.0\" ?><methodCall><methodName>create_certificate</methodName><params><param><value><string>oz7e1xz9r0mf0wgue22hsj8tgkhqyo74</string></value></param><param><value><string>testdomain_example_com</string></value></param><param><value><string>CERTIFICATE</string></value></param><param><value><string>PRIVATE_KEY</string></value></param><param><value><string>CHAIN CERTIFICATE</string></value></param></params></methodCall>\n")
        .to_return(status: 200, body: fixture('create_certificate_response.xml'))
    end

    let(:cert_name) { 'testdomain_example_com' }

    it 'creates certificate' do
      cert_installer.install!

      expect(WebMock).to have_requested(:post, "https://wfserverapi.example.com/")
        .with(body: "<?xml version=\"1.0\" ?><methodCall><methodName>create_certificate</methodName><params><param><value><string>oz7e1xz9r0mf0wgue22hsj8tgkhqyo74</string></value></param><param><value><string>testdomain_example_com</string></value></param><param><value><string>CERTIFICATE</string></value></param><param><value><string>PRIVATE_KEY</string></value></param><param><value><string>CHAIN CERTIFICATE</string></value></param></params></methodCall>\n")
    end
  end
end
