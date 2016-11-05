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
end
