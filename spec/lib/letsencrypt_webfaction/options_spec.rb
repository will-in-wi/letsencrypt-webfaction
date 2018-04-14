require 'letsencrypt_webfaction/options'

RSpec.describe LetsencryptWebfaction::Options do
  let(:username) { 'myusername' }
  let(:password) { 'mypassword' }
  let(:letsencrypt_account_email) { 'me@example.com' }
  let(:endpoint) { 'https://acme.example.com/' }
  let(:additional_config) { '' }
  let(:cert_name) { 'mycertname1' }
  let(:toml) do
    <<-TOML
      username = "#{username}"
      password = "#{password}"
      letsencrypt_account_email = "#{letsencrypt_account_email}"
      endpoint = "#{endpoint}"
      #{additional_config}
      [[certificate]]
      domains = [
        "test.example.com",
        "test1.example.com",
      ]
      #method = "http01"
      public = "~/webapps/myapp/public_html"
      name = "#{cert_name}"
      #key_size = 4096
    TOML
  end
  let(:options) { described_class.from_toml StringIO.new(toml) }

  describe '#valid?' do
    subject { options.valid? }
  end

  describe '#endpoint' do
    subject { options.endpoint }
    it { is_expected.to eq 'https://acme.example.com/' }
  end

  describe '#api_url' do
    subject { options.api_url }

    it('has default') { is_expected.to eq 'https://api.webfaction.com/' }

    context 'with overridden value' do
      let(:additional_config) { 'api_url = "http://api.example.com"' }

      it { is_expected.to eq 'http://api.example.com' }
    end
  end

  describe '#servername' do
    subject { options.servername }

    it 'has default' do
      # Uses local hostname by default.
      is_expected.to_not eq ''
      is_expected.to_not be_nil
    end

    context 'with overridden value' do
      let(:additional_config) { 'servername = "myserver"' }

      it { is_expected.to eq 'myserver' }
    end
  end

  describe '#errors' do
    subject { options.errors }

    context 'with valid arguments' do
      it { is_expected.to eq({}) }
    end

    context 'with invalid username' do
      let(:username) { nil }
      it { is_expected.to eq(username: "can't be blank") }
    end

    context 'with invalid password' do
      let(:password) { nil }
      it { is_expected.to eq(password: "can't be blank") }
    end

    context 'with multiple invalid values' do
      let(:username) { nil }
      let(:password) { nil }
      it { is_expected.to eq(username: "can't be blank", password: "can't be blank") }
    end

    context 'with invalid letsencrypt_account_email' do
      let(:letsencrypt_account_email) { '' }

      it { is_expected.to eq(letsencrypt_account_email: "can't be blank") }
    end

    context 'with invalid endpoint' do
      let(:endpoint) { '' }

      it { is_expected.to eq(endpoint: "can't be blank") }
    end

    context 'with invalid api_url' do
      let(:additional_config) { 'api_url = ""' }

      it { is_expected.to eq(api_url: "can't be blank") }
    end

    context 'with invalid servername' do
      let(:additional_config) { 'servername = ""' }

      it { is_expected.to eq(servername: "can't be blank") }
    end

    context 'with errors in certificates' do
      let(:cert_name) { '{}{}}' }

      it { is_expected.to eq(certificate: [{ name: 'can only include letters, numbers, and underscores' }]) }
    end
  end

  describe '#certificates' do
    subject { options.certificates }

    it 'returns certificates' do
      expect(subject.size).to eq 1
      expect(subject.first).to be_a LetsencryptWebfaction::Options::Certificate
      expect(subject.first.public_dirs).to eq ['~/webapps/myapp/public_html']
    end
  end
end
