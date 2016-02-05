require 'letsencrypt_webfaction/args_parser/defined_values_validator'

RSpec.describe LetsencryptWebfaction::ArgsParser::DefinedValuesValidator do
  let(:values) { [2048, 4096] }
  let(:validator) { LetsencryptWebfaction::ArgsParser::DefinedValuesValidator.new values }

  it 'is not valid when nil' do
    expect(validator.valid?(nil)).to eq false
  end

  it 'is not valid when item is not in list' do
    expect(validator.valid?('skjdhfd')).to eq false
  end

  it 'is not valid when integer item is not in list' do
    expect(validator.valid?(1234)).to eq false
  end

  it 'is valid when contains value in list' do
    expect(validator.valid?(2048)).to eq true
  end
end
