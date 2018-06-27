require 'letsencrypt_webfaction/application/init'

RSpec.describe LetsencryptWebfaction::Application::Init, :uses_tmp_dir do
  it 'creates the configuration file' do
    expect do
      described_class.new([]).run!
    end.to output(/Copied configuration file/).to_stdout
    expect(TEMP_DIR.join('letsencrypt_webfaction.toml')).to be_exist
    stat = TEMP_DIR.join('letsencrypt_webfaction.toml').stat
    expect(stat.mode).to eq 0o100600
  end

  it 'does not overwrite the configuration file' do
    config_path = TEMP_DIR.join('letsencrypt_webfaction.toml')
    config_path.write('blahblahblah')
    expect do
      described_class.new([]).run!
    end.to output(/Config file already exists/).to_stdout
    expect(config_path.read).to eq 'blahblahblah'
  end

  it 'creates the account private key' do
    expect do
      described_class.new([]).run!
    end.to output(/Generated and stored account private key/).to_stdout
    key_path = TEMP_DIR.join('.config', 'letsencrypt_webfaction', 'account_key.pem')
    expect(key_path).to be_exist
    expect(key_path.size).to be > 2000
  end

  it 'does not overwrite the account private key' do
    key_path = TEMP_DIR.join('.config', 'letsencrypt_webfaction', 'account_key.pem')
    FileUtils.mkdir_p key_path.parent
    key_path.write('blahblahblah')
    expect do
      described_class.new([]).run!
    end.to output(/Account private key already exists/).to_stdout
    expect(key_path.read).to eq 'blahblahblah'
  end

  it 'outputs useful information' do
    expect do
      described_class.new([]).run!
    end.to output(/Your system is set up/).to_stdout
  end
end
