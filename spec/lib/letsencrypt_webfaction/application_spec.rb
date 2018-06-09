require 'letsencrypt_webfaction/application'

RSpec.describe LetsencryptWebfaction::Application do
  describe '.new' do
    let(:args) { [] }
    subject { described_class.new(args) }

    context 'with "init"' do
      let(:args) { %w[init] }

      it { is_expected.to be_a LetsencryptWebfaction::Application::Init }
    end

    context 'with "run"', :uses_tmp_dir do
      let(:args) { %w[run] }

      before :each do
        FileUtils.cp FIXTURE_DIR.join('test_valid_config.toml'), TEMP_DIR.join('letsencrypt_webfaction.toml')
      end

      it { is_expected.to be_a LetsencryptWebfaction::Application::Run }
    end

    context 'with unsupported command' do
      let(:args) { %w[blahblah] }

      it 'shows error message' do
        expect do
          subject
        end.to raise_error(LetsencryptWebfaction::AppExitError).and output(/Unsupported command `blahblah`/).to_stderr
      end

      it 'shows valid commands' do
        expect do
          subject
        end.to raise_error(LetsencryptWebfaction::AppExitError).and output(/Must be one of init, run/).to_stderr
      end
    end

    context 'with v2 command' do
      let(:args) { ['--domains', 'example.com,test.example.com', '--public', '~/webapps/mysite/', '--cert_name', 'mycert'] }

      it 'shows error message' do
        expect do
          subject
        end.to raise_error(LetsencryptWebfaction::AppExitError).and output(/It looks like you are trying to run a version 2 command/).to_stderr
      end
    end

    context 'with nothing' do
      let(:args) { [] }

      it 'shows error message' do
        expect do
          subject
        end.to raise_error(LetsencryptWebfaction::AppExitError).and output(/Missing command/).to_stderr
      end
    end
  end
end
