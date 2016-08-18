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

  context 'when not reachable' do
    it 'outputs helpful text' do
      challenge = double('challenge')
      allow(challenge).to receive(:filename).and_return('file01.txt', 'file02.txt')
      allow(challenge).to receive(:file_content).and_return('file01 content', 'file02 content')
      allow(challenge).to receive(:request_verification)
      allow(challenge).to receive(:verify_status).and_return('pending')
      allow(challenge).to receive(:error).and_return({'detail' => 'Pretend failure'})

      authorization = double('authorization')
      allow(authorization).to receive(:http01).and_return(challenge)
      allow(authorization).to receive(:domain).and_return(*domains)

      client = double('client')
      allow(client).to receive(:authorize).and_return(authorization)

      dv = LetsencryptWebfaction::DomainValidator.new domains, client, public_dir

      # Speed up sleep
      allow_any_instance_of(Object).to receive(:sleep)

      expected_output = <<-ERR
Failed to verify statuses.
example.com: Pretend failure
Make sure that you can access http://example.com/file02.txt
www.example.com: Pretend failure
Make sure that you can access http://www.example.com/file02.txt
      ERR

      expect do
        dv.validate!
      end.to output(expected_output).to_stderr
    end
  end

  context 'when partially reachable' do
    it 'outputs helpful text' do
      challenge1 = double('challenge1')
      allow(challenge1).to receive(:filename).and_return('file01.txt')
      allow(challenge1).to receive(:file_content).and_return('file01 content')
      allow(challenge1).to receive(:request_verification)
      allow(challenge1).to receive(:verify_status).and_return('pending')
      allow(challenge1).to receive(:error).and_return({'detail' => 'Pretend failure'})

      challenge2 = double('challenge2')
      allow(challenge2).to receive(:filename).and_return('file02.txt')
      allow(challenge2).to receive(:file_content).and_return('file02 content')
      allow(challenge2).to receive(:request_verification)
      allow(challenge2).to receive(:verify_status).and_return('valid')

      authorization = double('authorization')
      allow(authorization).to receive(:http01).and_return(challenge1, challenge2)
      allow(authorization).to receive(:domain).and_return(*domains)

      client = double('client')
      allow(client).to receive(:authorize).and_return(authorization)

      dv = LetsencryptWebfaction::DomainValidator.new domains, client, public_dir

      # Speed up sleep
      allow_any_instance_of(Object).to receive(:sleep)

      expected_output = <<-ERR
Failed to verify statuses.
example.com: Pretend failure
Make sure that you can access http://example.com/file01.txt
www.example.com: Success
      ERR

      expect do
        dv.validate!
      end.to output(expected_output).to_stderr
    end
  end
end
