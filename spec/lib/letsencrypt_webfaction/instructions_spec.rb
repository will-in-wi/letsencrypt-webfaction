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
end
