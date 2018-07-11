require 'letsencrypt_webfaction/application/version'

RSpec.describe LetsencryptWebfaction::Application::Version do
  it 'outputs the version' do
    expect do
      described_class.new(['--version']).run!
    end.to output(/\A\d+\.\d+\.\d+\Z/).to_stdout
  end
end
