require 'letsencrypt_webfaction/args_parser'

RSpec.describe LetsencryptWebfaction::ArgsParser do
  let(:args) { [] }
  let(:args_parser) { LetsencryptWebfaction::ArgsParser.new args }

  context 'without required arguments' do
    let(:args) { [] }

    it 'is not valid' do
      expect(args_parser.valid?).to eq false
    end

    it 'requires contact' do
      expect(args_parser.errors[:contact]).to eq ["Invalid contact ''"]
    end

    it 'requires domains' do
      expect(args_parser.errors[:domains]).to eq ["Invalid domains '[]'"]
    end

    it 'requires public' do
      expect(args_parser.errors[:public]).to eq ["Invalid public ''"]
    end
  end

  context 'with arguments' do
    let(:args) do
      [
        '--key_size', '2048',
        '--endpoint', 'https://acme.example.com/',
        '--contact', 'you@example.com',
        '--domains', 'example.com,www.example.com',
        '--public', '/home/myuser/webapps/myapp/public_html',
        '--output_dir', '/home/myuser/le1_certs/',
        '--account_email', 'myemail@example.com',
        '--support_email', 'acct@example.com'
      ]
    end

    it 'is valid' do
      expect(args_parser.valid?).to eq true
    end

    it 'overrides key_size' do
      expect(args_parser.key_size).to eq 2048
    end

    it 'overrides endpoint' do
      expect(args_parser.endpoint).to eq 'https://acme.example.com/'
    end

    it 'overrides contact' do
      expect(args_parser.contact).to eq 'you@example.com'
    end

    it 'overrides domains' do
      expect(args_parser.domains).to eq ['example.com', 'www.example.com']
    end

    it 'overrides public' do
      expect(args_parser.public).to eq '/home/myuser/webapps/myapp/public_html'
    end

    it 'overrides output_dir' do
      expect(args_parser.output_dir).to eq '/home/myuser/le1_certs/'
    end
  end

  context 'returns help information' do
    let(:args) { ['--help'] }

    it 'exits and outputs help text' do
      expect { args_parser }.to raise_error(SystemExit).and output(/Usage: get_cert \[options\]/).to_stdout
    end
  end

  context 'loads config' do
    let(:args) { ['--config', 'spec/fixtures/test.config.yml'] }

    it 'is valid' do
      expect(args_parser.valid?).to eq true
    end

    it 'sets key_size' do
      expect(args_parser.key_size).to eq 2048
    end

    it 'sets endpoint' do
      expect(args_parser.endpoint).to eq 'https://acme.example.com/'
    end

    it 'sets contact' do
      expect(args_parser.contact).to eq 'you@example.com'
    end

    it 'sets domains' do
      expect(args_parser.domains).to eq ['example.com', 'www.example.com']
    end

    it 'sets public' do
      expect(args_parser.public).to eq '/home/myuser/webapps/myapp/public_html'
    end

    it 'sets output_dir' do
      expect(args_parser.output_dir).to eq '/home/myuser/le2_certs/'
    end
  end

  context 'overrides configuration with arguments' do
    let(:args) do
      [
        '--config', 'spec/fixtures/test.config.yml',
        '--key_size', '4096',
        '--endpoint', 'https://acme1.example.com/',
        '--contact', 'you1@example.com',
        '--domains', 'example.org,www1.example.org',
        '--public', '/home/myuser/webapps/myapp1/public_html',
        '--output_dir', '/home/myuser/le1_certs/',
        '--account_email', 'myemail@example.com',
        '--support_email', 'acct@example.com'
      ]
    end

    it 'is valid' do
      expect(args_parser.valid?).to eq true
    end

    it 'has no errors' do
      expect(args_parser.errors).to be_empty
    end

    it 'overrides key_size' do
      expect(args_parser.key_size).to eq 4096
    end

    it 'overrides endpoint' do
      expect(args_parser.endpoint).to eq 'https://acme1.example.com/'
    end

    it 'overrides contact' do
      expect(args_parser.contact).to eq 'you1@example.com'
    end

    it 'overrides domains' do
      expect(args_parser.domains).to eq ['example.org', 'www1.example.org']
    end

    it 'overrides public' do
      expect(args_parser.public).to eq '/home/myuser/webapps/myapp1/public_html'
    end

    it 'overrides output_dir' do
      expect(args_parser.output_dir).to eq '/home/myuser/le1_certs/'
    end
  end

  context 'with default configuration' do
    let(:args) { [] }

    it 'has key_size' do
      expect(args_parser.key_size).to eq 4096
    end

    it 'has endpoint' do
      expect(args_parser.endpoint).to eq 'https://acme-v01.api.letsencrypt.org/'
    end

    it 'has output_dir' do
      expect(args_parser.output_dir).to eq '~/le_certs/'
    end

    it 'does not have contact' do
      expect(args_parser.contact).to eq ''
    end

    it 'does not have domains' do
      expect(args_parser.domains).to eq []
    end

    it 'does not have public' do
      expect(args_parser.public).to eq ''
    end
  end
end
