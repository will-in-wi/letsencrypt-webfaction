require 'letsencrypt_webfaction/application'

RSpec.describe LetsencryptWebfaction::Application do
  describe '.new' do
    let(:args) { [] }
    subject { described_class.new(args) }

    context 'with "init"' do
      let(:args) { %w[init --arg1] }

      it { is_expected.to be_a LetsencryptWebfaction::Application::Init }
    end

    context 'with "run"' do
      let(:args) { %w[run --arg1] }

      it { is_expected.to be_a LetsencryptWebfaction::Application::Run }
    end

    context 'with unsupported command' do
      let(:args) { %w[blahblah --arg1] }

      it 'shows error message' do
        expect do
          subject
        end.to output(/Unsupported command `blahblah`/).to_stderr
      end

      it 'shows valid commands' do
        expect do
          subject
        end.to output(/Must be one of init, run/).to_stderr
      end
    end

    context 'with nothing' do
      let(:args) { [] }

      it 'shows error message' do
        expect do
          subject
        end.to output(/Missing command/).to_stderr
      end
    end
  end
end
