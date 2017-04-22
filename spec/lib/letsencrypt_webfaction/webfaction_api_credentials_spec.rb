require 'letsencrypt_webfaction/webfaction_api_credentials'

RSpec.describe LetsencryptWebfaction::WebfactionApiCredentials do
  let(:username) { 'myusername' }
  let(:password) { 'mypassword' }
  let(:servername) { 'myservername' }
  let(:api_server) { 'https://wfserverapi.example.com/' }

  let(:creds) { LetsencryptWebfaction::WebfactionApiCredentials.new username: username, password: password, servername: servername, api_server: api_server }

  describe '#username' do
    subject { creds.username }

    it { is_expected.to eq 'myusername' }
  end

  describe '#password' do
    subject { creds.password }

    it { is_expected.to eq 'mypassword' }
  end

  describe '#servername' do
    subject { creds.servername }

    it { is_expected.to eq 'myservername' }
  end

  describe '#api_server' do
    subject { creds.api_server }

    it { is_expected.to eq 'https://wfserverapi.example.com/' }
  end

  describe '#valid?' do
    subject { creds.valid? }

    context 'with valid password' do
      before :each do
        stub_request(:post, 'https://wfserverapi.example.com/')
          .with(body: "<?xml version=\"1.0\" ?><methodCall><methodName>login</methodName><params><param><value><string>myusername</string></value></param><param><value><string>mypassword</string></value></param><param><value><string>myservername</string></value></param><param><value><i4>2</i4></value></param></params></methodCall>\n")
          .to_return(status: 200, body: fixture('login_response.xml'))
      end

      it { is_expected.to eq true }
    end

    context 'with invalid password' do
      before :each do
        stub_request(:post, 'https://wfserverapi.example.com/')
          .with(body: "<?xml version=\"1.0\" ?><methodCall><methodName>login</methodName><params><param><value><string>myusername</string></value></param><param><value><string>mypassword</string></value></param><param><value><string>myservername</string></value></param><param><value><i4>2</i4></value></param></params></methodCall>\n")
          .to_raise(XMLRPC::FaultException.new(1, 'LoginError'))
      end

      it { is_expected.to eq false }
    end
  end
end
