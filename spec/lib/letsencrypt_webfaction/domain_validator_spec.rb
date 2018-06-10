require 'acme/client'
require 'letsencrypt_webfaction/domain_validator'

RSpec.describe LetsencryptWebfaction::DomainValidator do
  let(:domains) { ['example.com', 'www.example.com'] }
  let(:public_dir) { ['spec/tmp/'] }

  after :each do
    # Clean out the test folder.
    FileUtils.rm_f Dir.glob('spec/tmp/*')
  end

  it '#validate! works' do
    challenge1 = instance_double(Acme::Client::Resources::Challenges::HTTP01)
    allow(challenge1).to receive(:filename).and_return('file01.txt')
    allow(challenge1).to receive(:file_content).and_return('file01 content')
    allow(challenge1).to receive(:request_verification).and_return(true)
    authorization1 = instance_double(Acme::Client::Resources::Authorization)
    allow(authorization1).to receive(:verify_status).and_return('pending', 'valid')
    allow(challenge1).to receive(:authorization).and_return(authorization1)

    challenge2 = instance_double(Acme::Client::Resources::Challenges::HTTP01)
    allow(challenge2).to receive(:filename).and_return('file02.txt')
    allow(challenge2).to receive(:file_content).and_return('file02 content')
    allow(challenge2).to receive(:request_verification).and_return(true)
    authorization2 = instance_double(Acme::Client::Resources::Authorization)
    allow(authorization2).to receive(:verify_status).and_return('pending', 'valid')
    allow(challenge2).to receive(:authorization).and_return(authorization2)

    authorization = instance_double(Acme::Client::Resources::Authorization)
    allow(authorization).to receive(:http01).and_return(challenge1, challenge2)

    client = instance_double(Acme::Client)
    allow(client).to receive(:authorize).and_return(authorization)

    dv = LetsencryptWebfaction::DomainValidator.new domains, client, public_dir

    # Speed up sleep
    allow_any_instance_of(Object).to receive(:sleep)

    dv.validate!

    path = Pathname.new(public_dir.first)
    expect(path.join('file01.txt')).to be_exist
    expect(path.join('file02.txt')).to be_exist
  end

  context 'with multiple public dirs' do
    let(:public_dir) { ['spec/tmp/test2/', 'spec/tmp/test1/'] }

    it 'creates multiple files' do
      challenge1 = instance_double(Acme::Client::Resources::Challenges::HTTP01)
      allow(challenge1).to receive(:filename).and_return('file01.txt')
      allow(challenge1).to receive(:file_content).and_return('file01 content')
      allow(challenge1).to receive(:request_verification).and_return(true)
      authorization1 = instance_double(Acme::Client::Resources::Authorization)
      allow(authorization1).to receive(:verify_status).and_return('pending', 'valid')
      allow(challenge1).to receive(:authorization).and_return(authorization1)

      challenge2 = instance_double(Acme::Client::Resources::Challenges::HTTP01)
      allow(challenge2).to receive(:filename).and_return('file02.txt')
      allow(challenge2).to receive(:file_content).and_return('file02 content')
      allow(challenge2).to receive(:request_verification).and_return(true)
      authorization2 = instance_double(Acme::Client::Resources::Authorization)
      allow(authorization2).to receive(:verify_status).and_return('pending', 'valid')
      allow(challenge2).to receive(:authorization).and_return(authorization2)

      authorization = instance_double(Acme::Client::Resources::Authorization)
      allow(authorization).to receive(:http01).and_return(challenge1, challenge2)

      client = instance_double(Acme::Client)
      allow(client).to receive(:authorize).and_return(authorization)

      dv = LetsencryptWebfaction::DomainValidator.new domains, client, public_dir

      # Speed up sleep
      allow_any_instance_of(Object).to receive(:sleep)

      dv.validate!

      public_dir.map { |dir| Pathname.new(dir) }.each do |path|
        expect(path.join('file01.txt')).to be_exist
        expect(path.join('file02.txt')).to be_exist
      end
    end
  end

  context 'when not reachable' do
    it 'outputs helpful text' do
      challenge = instance_double(Acme::Client::Resources::Challenges::HTTP01)
      allow(challenge).to receive(:filename).and_return('file01.txt', 'file02.txt')
      allow(challenge).to receive(:file_content).and_return('file01 content', 'file02 content')
      allow(challenge).to receive(:request_verification).and_return(true)
      authorization = instance_double(Acme::Client::Resources::Authorization)
      allow(authorization).to receive(:verify_status).and_return('invalid')
      allow(challenge).to receive(:authorization).and_return(authorization)
      allow(challenge).to receive(:error).and_return('detail' => 'Pretend failure')

      authorization = instance_double(Acme::Client::Resources::Authorization)
      allow(authorization).to receive(:http01).and_return(challenge)
      allow(authorization).to receive(:domain).and_return(*domains)

      client = instance_double(Acme::Client)
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
      challenge1 = instance_double(Acme::Client::Resources::Challenges::HTTP01)
      allow(challenge1).to receive(:filename).and_return('file01.txt')
      allow(challenge1).to receive(:file_content).and_return('file01 content')
      allow(challenge1).to receive(:request_verification).and_return(true)
      authorization1 = instance_double(Acme::Client::Resources::Authorization)
      allow(authorization1).to receive(:verify_status).and_return('invalid')
      allow(challenge1).to receive(:authorization).and_return(authorization1)
      allow(challenge1).to receive(:error).and_return('detail' => 'Pretend failure')

      challenge2 = instance_double(Acme::Client::Resources::Challenges::HTTP01)
      allow(challenge2).to receive(:filename).and_return('file02.txt')
      allow(challenge2).to receive(:file_content).and_return('file02 content')
      allow(challenge2).to receive(:request_verification).and_return(true)
      authorization2 = instance_double(Acme::Client::Resources::Authorization)
      allow(authorization2).to receive(:verify_status).and_return('valid')
      allow(challenge2).to receive(:authorization).and_return(authorization2)

      authorization = instance_double(Acme::Client::Resources::Authorization)
      allow(authorization).to receive(:http01).and_return(challenge1, challenge2)
      allow(authorization).to receive(:domain).and_return(*domains)

      client = instance_double(Acme::Client)
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

  context 'when never resolves' do
    let(:domains) { ['example.com'] }
    it 'outputs helpful text' do
      challenge = instance_double(Acme::Client::Resources::Challenges::HTTP01)
      allow(challenge).to receive(:filename).and_return('file01.txt')
      allow(challenge).to receive(:file_content).and_return('file01 content')
      allow(challenge).to receive(:request_verification).and_return(true)
      authorization = instance_double(Acme::Client::Resources::Authorization)
      allow(authorization).to receive(:verify_status).and_return('pending')
      allow(challenge).to receive(:authorization).and_return(authorization)
      # allow(challenge).to receive(:error).and_return('detail' => 'Pretend failure')

      allow(authorization).to receive(:http01).and_return(challenge)
      allow(authorization).to receive(:domain).and_return(*domains)

      client = instance_double(Acme::Client)
      allow(client).to receive(:authorize).and_return(authorization)

      dv = LetsencryptWebfaction::DomainValidator.new domains, client, public_dir

      # Speed up sleep
      allow_any_instance_of(Object).to receive(:sleep)

      expected_output = <<-ERR
Failed to verify statuses.
example.com: Still pending, but timed out
      ERR

      expect do
        dv.validate!
      end.to output(expected_output).to_stderr
    end
  end

  context 'with failed validation request' do
    let(:domains) { ['example.com'] }
    it 'outputs helpful text' do
      challenge = instance_double(Acme::Client::Resources::Challenges::HTTP01)
      allow(challenge).to receive(:filename).and_return('file01.txt')
      allow(challenge).to receive(:file_content).and_return('file01 content')
      allow(challenge).to receive(:request_verification).and_return(false)
      authorization = instance_double(Acme::Client::Resources::Authorization)
      allow(challenge).to receive(:authorization).and_return(authorization)

      allow(authorization).to receive(:http01).and_return(challenge)
      allow(authorization).to receive(:domain).and_return(*domains)

      client = instance_double(Acme::Client)
      allow(client).to receive(:authorize).and_return(authorization)

      dv = LetsencryptWebfaction::DomainValidator.new domains, client, public_dir

      # Speed up sleep
      allow_any_instance_of(Object).to receive(:sleep)

      expect { dv.validate! }.to output("Failed to request validations.\n").to_stderr
    end
  end

  context 'with unexpected response status' do
    let(:domains) { ['example.com'] }
    it 'outputs helpful text' do
      challenge = instance_double(Acme::Client::Resources::Challenges::HTTP01)
      allow(challenge).to receive(:filename).and_return('file01.txt')
      allow(challenge).to receive(:file_content).and_return('file01 content')
      allow(challenge).to receive(:request_verification).and_return(true)
      authorization = instance_double(Acme::Client::Resources::Authorization)
      allow(authorization).to receive(:verify_status).and_return('ARRRGH!!!!')
      allow(challenge).to receive(:authorization).and_return(authorization)
      # allow(challenge).to receive(:error).and_return('detail' => 'Pretend failure')

      allow(authorization).to receive(:http01).and_return(challenge)
      allow(authorization).to receive(:domain).and_return(*domains)

      client = instance_double(Acme::Client)
      allow(client).to receive(:authorize).and_return(authorization)

      dv = LetsencryptWebfaction::DomainValidator.new domains, client, public_dir

      # Speed up sleep
      allow_any_instance_of(Object).to receive(:sleep)

      expected_output = <<-ERR
Failed to verify statuses.
example.com: Unexpected authorization status ARRRGH!!!!
      ERR

      expect do
        dv.validate!
      end.to output(expected_output).to_stderr
    end
  end
end
