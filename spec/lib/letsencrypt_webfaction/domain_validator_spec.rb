require 'letsencrypt_webfaction/domain_validator'

RSpec.describe LetsencryptWebfaction::DomainValidator do
  let(:domains) { ['example.com', 'www.example.com'] }
  let(:public_dir) { 'spec/tmp/' }

  after :each do
    # Clean out the test folder.
    FileUtils.rm_f Dir.glob("#{public_dir}/*")
  end

  it '#validate! works' do
    challenge = double('challenge')
    allow(challenge).to receive(:filename).and_return('file01.txt', 'file02.txt')
    allow(challenge).to receive(:file_content).and_return('file01 content', 'file02 content')
    allow(challenge).to receive(:request_verification)
    allow(challenge).to receive(:verify_status).and_return('pending', 'valid')

    authorization = double('authorization')
    allow(authorization).to receive(:http01).and_return(challenge)

    client = double('client')
    allow(client).to receive(:authorize).and_return(authorization)

    dv = LetsencryptWebfaction::DomainValidator.new domains, client, public_dir

    # Speed up sleep
    allow_any_instance_of(Object).to receive(:sleep)

    dv.validate!
  end
end
