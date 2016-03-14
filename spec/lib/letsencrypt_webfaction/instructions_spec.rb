require 'letsencrypt_webfaction/instructions'

RSpec.describe LetsencryptWebfaction::Instructions do
  let(:output_dir) { '/test/folder' }
  let(:domains) { ['www.example.com', 'example.com', 'www.example.org', 'example.org'] }
  let(:instructions) { LetsencryptWebfaction::Instructions.new output_dir, domains }

  describe '#full_message' do
    it 'contains the entire message' do
      expect(instructions.full_message).to eq "LetsEncrypt Webfaction has generated a new certificate for www.example.com, example.com, www.example.org, and example.org. The certificates have been placed in /test/folder. WebFaction support has been contacted with the following message:\n\nPlease apply the new certificate in /test/folder to www.example.com, example.com, www.example.org, and example.org. Thanks!"
    end
  end

  describe '#context' do
    let(:support_email) { true }
    subject { instructions.context support_email: support_email }

    it { is_expected.to include 'LetsEncrypt Webfaction has generated a new certificate for www.example.com, example.com, www.example.org, and example.org. The certificates have been placed in /test/folder.' }

    context 'with no support_email' do
      let(:support_email) { false }

      it { is_expected.to include 'Go to https://help.webfaction.com, log in, and paste the following text into a new ticket:' }
      it { is_expected.to_not include 'WebFaction support has been contacted' }
    end

    context 'with support_email' do
      it { is_expected.to include 'WebFaction support has been contacted' }
      it { is_expected.to_not include 'Go to https://help.webfaction.com, log in, and paste the following text into a new ticket:' }
    end

    context 'with single domain' do
      let(:domains) { ['example.com'] }

      it 'has domain' do
        expect(subject).to include 'example.com'
      end

      it 'has no www domain' do
        expect(subject).to_not include 'www.example.com'
      end

      it 'has no comma' do
        expect(subject).to_not include 'example.com, '
      end

      it 'has no conjunction' do
        expect(subject).to_not include 'example.com and '
      end

      it 'has no oxford comma' do
        expect(subject).to_not include 'example.com, and '
      end
    end

    context 'with two domains' do
      let(:domains) { ['example.com', 'www.example.com'] }
      it 'has domain' do
        expect(subject).to include 'example.com and www.example.com'
      end

      it 'has no comma' do
        expect(subject).to_not include 'example.com, '
      end

      it 'has no oxford comma' do
        expect(subject).to_not include 'example.com, and '
      end
    end

    context 'with no domains' do
      let(:domains) { [] }
      it 'has no domain' do
        expect(subject).to_not include 'example.com'
      end
    end
  end

  describe '#instructions' do
    subject { instructions.instructions }

    it { is_expected.to eq 'Please apply the new certificate in /test/folder to www.example.com, example.com, www.example.org, and example.org. Thanks!' }
  end
end
