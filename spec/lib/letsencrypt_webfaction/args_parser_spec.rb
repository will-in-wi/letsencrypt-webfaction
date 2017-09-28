require 'letsencrypt_webfaction'
require 'letsencrypt_webfaction/args_parser'

RSpec.describe LetsencryptWebfaction::ArgsParser do
  let(:args) { [] }
  let(:args_parser) { LetsencryptWebfaction::ArgsParser.new args }

  describe '--version' do
    let(:args) { ['--version'] }

    it 'returns version number' do
      expect { args_parser }.to output("#{LetsencryptWebfaction::VERSION}\n").to_stdout.and raise_error(SystemExit)
    end
  end

  context 'without required arguments' do
    let(:args) { [] }

    it 'is not valid' do
      expect(args_parser.valid?).to eq false
    end

    it 'requires letsencrypt_account_email' do
      expect(args_parser.errors[:letsencrypt_account_email]).to eq ["Invalid letsencrypt_account_email ''"]
    end

    it 'requires domains' do
      expect(args_parser.errors[:domains]).to eq ["Invalid domains '[]'"]
    end

    it 'requires public' do
      expect(args_parser.errors[:public]).to eq ["Invalid public '[]'"]
    end

    it 'requires username' do
      expect(args_parser.errors[:username]).to eq ["Invalid username ''"]
    end

    it 'requires password' do
      expect(args_parser.errors[:password]).to eq ["Invalid password ''"]
    end
  end

  context 'with arguments' do
    let(:args) do
      [
        '--key_size', '2048',
        '--endpoint', 'https://acme.example.com/',
        '--domains', 'example.com,www.example.com',
        '--public', '/home/myuser/webapps/myapp/public_html',
        '--output_dir', '/home/myuser/le1_certs/',
        '--letsencrypt_account_email', 'acct2@example.com',
        '--username', 'myusername',
        '--password', 'mypassword',
        '--servername', 'Web123',
        '--cert_name', 'blah_server',
      ]
    end

    it 'is valid' do
      expect(args_parser.valid?).to eq true
    end

    it 'has no errors' do
      expect(args_parser.errors).to eq({})
    end

    it 'overrides key_size' do
      expect(args_parser.key_size).to eq 2048
    end

    it 'overrides endpoint' do
      expect(args_parser.endpoint).to eq 'https://acme.example.com/'
    end

    it 'overrides domains' do
      expect(args_parser.domains).to eq ['example.com', 'www.example.com']
    end

    it 'overrides public' do
      expect(args_parser.public).to eq ['/home/myuser/webapps/myapp/public_html']
    end

    it 'overrides output_dir' do
      expect(args_parser.output_dir).to eq '/home/myuser/le1_certs/'
    end

    it 'overrides letsencrypt_account_email' do
      expect(args_parser.letsencrypt_account_email).to eq 'acct2@example.com'
    end

    it 'overrides username' do
      expect(args_parser.username).to eq 'myusername'
    end

    it 'overrides password' do
      expect(args_parser.password).to eq 'mypassword'
    end

    it 'overrides servername' do
      expect(args_parser.servername).to eq 'Web123'
    end

    it 'overrides cert_name' do
      expect(args_parser.cert_name).to eq 'blah_server'
    end

    it 'has an empty hash of email_configuration' do
      expect(args_parser.email_configuration).to eq({})
    end
  end

  context 'returns help information' do
    let(:args) { ['--help'] }

    it 'exits and outputs help text' do
      expect { args_parser }.to raise_error(SystemExit).and output(/Usage: letsencrypt_webfaction \[options\]/).to_stdout
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

  context 'loads partial config' do
    let(:args) { ['--config', 'spec/fixtures/test_partial.config.yml'] }

    it 'is valid' do
      expect(args_parser.valid?).to eq true
    end

    it 'sets key_size' do
      expect(args_parser.key_size).to eq 4096
    end

    it 'sets endpoint' do
      expect(args_parser.endpoint).to eq 'https://acme-v01.api.letsencrypt.org/'
    end

    it 'sets domains' do
      expect(args_parser.domains).to eq ['example.com', 'www.example.com']
    end

    it 'sets public' do
      expect(args_parser.public).to eq '/home/myuser/webapps/myapp/public_html'
    end

    it 'sets output_dir' do
      expect(args_parser.output_dir).to eq '~/le_certs/'
    end

    it 'has cert_name' do
      # Uses a converted common name
      expect(args_parser.cert_name).to eq 'example_com'
    end
  end

  context 'overrides configuration with arguments' do
    let(:args) do
      [
        '--config', 'spec/fixtures/test.config.yml',
        '--key_size', '4096',
        '--endpoint', 'https://acme1.example.com/',
        '--domains', 'example.org,www1.example.org',
        '--public', '/home/myuser/webapps/myapp1/public_html',
        '--output_dir', '/home/myuser/le1_certs/',
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

    it 'overrides domains' do
      expect(args_parser.domains).to eq ['example.org', 'www1.example.org']
    end

    it 'overrides public' do
      expect(args_parser.public).to eq ['/home/myuser/webapps/myapp1/public_html']
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

    it 'has api_url' do
      expect(args_parser.api_url).to eq 'https://api.webfaction.com/'
    end

    it 'has servername' do
      # Uses local hostname by default.
      expect(args_parser.servername).to_not eq ''
      expect(args_parser.servername).to_not be_nil
    end

    it 'does not have cert_name' do
      # Uses a converted common name
      expect(args_parser.cert_name).to eq ''
    end

    it 'does not have domains' do
      expect(args_parser.domains).to eq []
    end

    it 'does not have public' do
      expect(args_parser.public).to eq []
    end

    it 'does not have username' do
      expect(args_parser.username).to eq ''
    end

    it 'does not have password' do
      expect(args_parser.password).to eq ''
    end
  end
end
