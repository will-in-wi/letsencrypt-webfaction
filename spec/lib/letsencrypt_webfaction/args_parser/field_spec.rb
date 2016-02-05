require 'letsencrypt_webfaction/args_parser/field'

RSpec.describe LetsencryptWebfaction::ArgsParser::Field do
  let(:identifier) { :field1 }
  let(:description) { 'My description' }
  let(:validators) { [] }
  let(:field) { LetsencryptWebfaction::ArgsParser::Field.new identifier, description, validators }

  it 'has getters' do
    expect(field.identifier).to eq identifier
    expect(field.description).to eq description
  end

  it 'sanitizes' do
    # Identity function. Returns its input.
    expect(field.sanitize('test')).to eq 'test'
  end

  it 'validates' do
    # With no validators, it just returns true.
    expect(field.valid?('test')).to eq true
  end

  context LetsencryptWebfaction::ArgsParser::Field::IntegerField do
    let(:field) { LetsencryptWebfaction::ArgsParser::Field::IntegerField.new identifier, description, validators }

    it 'sanitizes' do
      # Identity function. Returns its input.
      expect(field.sanitize('1234')).to eq 1234
    end
  end

  context LetsencryptWebfaction::ArgsParser::Field::ListField do
    let(:field) { LetsencryptWebfaction::ArgsParser::Field::ListField.new identifier, description, validators }

    it 'sanitizes' do
      # Identity function. Returns its input.
      expect(field.sanitize('1,2,3,4')).to eq %w(1 2 3 4)
    end
  end
end
