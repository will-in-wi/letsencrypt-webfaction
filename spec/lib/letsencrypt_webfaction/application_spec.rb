require 'letsencrypt_webfaction/application'

RSpec.describe LetsencryptWebfaction::Application do
  PUBLIC_DIR = TEMP_DIR.join('example').freeze
  before :each do
    FileUtils.mkdir_p TEMP_DIR
    FileUtils.mkdir_p PUBLIC_DIR
  end

  after :each do
    FileUtils.rm_rf TEMP_DIR
  end

  before :each do
    stub_request(:post, 'https://wfserverapi.example.com/')
      .with(body: "<?xml version=\"1.0\" ?><methodCall><methodName>login</methodName><params><param><value><string>myusername</string></value></param><param><value><string>mypassword</string></value></param><param><value><string>myservername</string></value></param><param><value><i4>2</i4></value></param></params></methodCall>\n")
      .to_return(status: 200, body: fixture('login_response.xml'))
    stub_request(:post, 'https://wfserverapi.example.com/')
      .with(body: "<?xml version=\"1.0\" ?><methodCall><methodName>list_certificates</methodName><params><param><value><string>oz7e1xz9r0mf0wgue22hsj8tgkhqyo74</string></value></param></params></methodCall>\n")
      .to_return(status: 200, body: fixture('list_certificates_response.xml'))
    stub_request(:post, 'https://wfserverapi.example.com/')
      .with(body: "<?xml version=\"1.0\" ?><methodCall><methodName>create_certificate</methodName><params><param><value><string>oz7e1xz9r0mf0wgue22hsj8tgkhqyo74</string></value></param><param><value><string>www_example_com</string></value></param><param><value><string>CERTIFICATE</string></value></param><param><value><string>PRIVATE KEY</string></value></param><param><value><string>CHAIN!</string></value></param></params></methodCall>\n")
      .to_return(status: 200, body: fixture('create_certificate_response.xml'))
  end

  let(:args) do
    [
      '--account_email', 'contact@example.com',
      '--domains', 'www.example.com,example.com',
      '--public', PUBLIC_DIR.to_s,
      '--output_dir', TEMP_DIR.join('out').to_s,
      '--endpoint', 'http://localhost:4002',
      '--username', 'myusername',
      '--password', 'mypassword',
      '--servername', 'myservername',
      '--api_url', 'https://wfserverapi.example.com/',
    ]
  end
  let(:application) { LetsencryptWebfaction::Application.new(args) }

  describe '#run!' do
    before :each do
      # Set up doubles to avoid actual verification and communication with LE.
      challenge = double('challenge', filename: 'challenge1.txt', file_content: 'woohoo!', request_verification: nil, verify_status: 'valid')
      certificate = double('certificate', to_pem: 'CERTIFICATE', chain_to_pem: 'CHAIN!', fullchain_to_pem: 'FULLCHAIN!!')
      allow(certificate).to receive_message_chain(:request, :private_key, to_pem: 'PRIVATE KEY')
      client = double('client', new_certificate: certificate)
      allow(client).to receive_message_chain(:authorize, http01: challenge)
      allow(client).to receive_message_chain(:register, agree_terms: nil)
      allow(Acme::Client).to receive(:new) { client }

      # Run code.
      application.run!
    end
    it 'writes validation file' do
      expect(PUBLIC_DIR.join('challenge1.txt')).to exist
    end
  end

  describe '#run!' do
    context 'with invalid options' do
      let(:args) { [] }

      it 'raises argument error' do
        expect do
          application.run!
        end.to raise_error ArgumentError
      end
    end
  end
end
