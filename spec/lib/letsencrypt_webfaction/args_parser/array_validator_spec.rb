require 'letsencrypt_webfaction/args_parser/array_validator'

RSpec.describe LetsencryptWebfaction::ArgsParser::ArrayValidator do
  let(:validator) { LetsencryptWebfaction::ArgsParser::ArrayValidator.new }

  it 'is not valid when nil' do
    expect(validator.valid?(nil)).to eq false
  end

  it 'is not valid when empty string' do
    expect(validator.valid?('')).to eq false
  end

  it 'is not valid when empty array' do
    expect(validator.valid?([])).to eq false
  end

  it 'is valid when contains array values' do
    expect(validator.valid?(['sldflksjdf'])).to eq true
  end
end
