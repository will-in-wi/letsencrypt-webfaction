require 'letsencrypt_webfaction/args_parser/string_validator'

RSpec.describe LetsencryptWebfaction::ArgsParser::StringValidator do
  let(:validator) { LetsencryptWebfaction::ArgsParser::StringValidator.new }

  it 'is not valid when nil' do
    expect(validator.valid?(nil)).to eq false
  end

  it 'is not valid when empty string' do
    expect(validator.valid?('')).to eq false
  end

  it 'is valid when contains value' do
    expect(validator.valid?('sldflksjdf')).to eq true
  end
end
