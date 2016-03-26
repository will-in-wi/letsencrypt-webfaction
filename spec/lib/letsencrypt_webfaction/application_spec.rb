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

  let(:args) do
    [
      '--account_email', 'contact@example.com',
      '--domains', 'www.example.com,example.com',
      '--public', PUBLIC_DIR.to_s,
      '--output_dir', TEMP_DIR.join('out').to_s,
      '--support_email', 'support@example.com',
      '--endpoint', 'http://localhost:4002',
    ]
  end
  let(:application) { LetsencryptWebfaction::Application.new(args) }

  describe '#run!' do
    before :each do
      # Set up doubles.
      registration = double('registration', agree_terms: nil)
      challenge = double('challenge', filename: 'challenge1.txt', file_content: 'woohoo!', request_verification: nil, verify_status: 'valid')
      authorization = double('authorization', http01: challenge)
      priv_key = double('priv_key', to_pem: 'PRIVATE KEY')
      cert_request = double('cert_request', private_key: priv_key)
      certificate = double('certificate', request: cert_request, to_pem: 'CERTIFICATE', chain_to_pem: 'CHAIN!', fullchain_to_pem: 'FULLCHAIN!!')
      client = double('client', register: registration, authorize: authorization, new_certificate: certificate)
      allow(Acme::Client).to receive(:new) { client }

      Mail::TestMailer.deliveries.clear

      # Run code.
      application.run!
    end

    it 'sends emails' do
      expect(Mail::TestMailer.deliveries.length).to eq 2
    end

    it 'writes validation file' do
      expect(PUBLIC_DIR.join('challenge1.txt')).to exist
    end

    context 'output files' do
      subject { Dir.glob(TEMP_DIR.join('out/www.example.com/*/*')).map { |f| File.basename f } }

      it { is_expected.to include 'cert.pem' }
      it { is_expected.to include 'fullchain.pem' }
      it { is_expected.to include 'privkey.pem' }
    end

    context 'without support' do
      let(:args) do
        [
          '--account_email', 'contact@example.com',
          '--domains', 'www.example.com,example.com',
          '--public', PUBLIC_DIR.to_s,
          '--output_dir', TEMP_DIR.join('out').to_s,
          '--support_email', '',
          '--endpoint', 'http://localhost:4002',
        ]
      end

      it 'sends only one email' do
        expect(Mail::TestMailer.deliveries.length).to eq 1
      end
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
