require 'letsencrypt_webfaction/instructions'

RSpec.describe LetsencryptWebfaction::Instructions do
  let(:output_dir) { '/test/folder' }
  let(:domains) { ['www.example.com', 'example.com', 'www.example.org', 'example.org'] }
  let(:instructions) { LetsencryptWebfaction::Instructions.new output_dir, domains }

  it 'outputs directions' do
    expect(instructions.message).to eq 'LetsEncrypt Webfaction has generated a new certificate for www.example.com, example.com, www.example.org, and example.org. The certificates have been placed in /test/folder. You now need to request installation from the WebFaction support team.

Go to https://help.webfaction.com, log in, and paste the following text into a new ticket:

Please apply the new certificate in /test/folder to www.example.com, example.com, www.example.org, and example.org. Thanks!'
  end

  context 'with single domain' do
    let(:domains) { ['example.com'] }
    it 'has domain' do
      expect(instructions.message).to include 'example.com'
    end

    it 'has no www domain' do
      expect(instructions.message).to_not include 'www.example.com'
    end

    it 'has no comma' do
      expect(instructions.message).to_not include 'example.com, '
    end

    it 'has no conjunction' do
      expect(instructions.message).to_not include 'example.com and '
    end

    it 'has no oxford comma' do
      expect(instructions.message).to_not include 'example.com, and '
    end
  end

  context 'with two domains' do
    let(:domains) { ['example.com', 'www.example.com'] }
    it 'has domain' do
      expect(instructions.message).to include 'example.com and www.example.com'
    end

    it 'has no comma' do
      expect(instructions.message).to_not include 'example.com, '
    end

    it 'has no oxford comma' do
      expect(instructions.message).to_not include 'example.com, and '
    end
  end

  context 'with no domains' do
    let(:domains) { [] }
    it 'has no domain' do
      expect(instructions.message).to_not include 'example.com'
    end
  end
end
