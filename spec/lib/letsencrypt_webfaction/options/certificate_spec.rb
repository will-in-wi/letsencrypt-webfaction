# frozen_string_literal: true

require 'letsencrypt_webfaction/options/certificate'
require 'letsencrypt_webfaction/errors'

RSpec.describe LetsencryptWebfaction::Options::Certificate do
  let(:domains) { 'www.example.com' }
  let(:validation_method) { 'http01' }
  let(:public_dirs) { '~/webapps/blah' }
  let(:cert_name) { 'blahblah' }
  let(:key_size) { nil }
  let(:args) do
    {
      'domains' => domains,
      'method' => validation_method,
      'public' => public_dirs,
      'name' => cert_name,
      'key_size' => key_size,
    }
  end
  let(:cert) { described_class.new args }

  describe '#domains' do
    subject { cert.domains }

    context 'with blank' do
      let(:domains) { '' }
      it { is_expected.to eq [] }
    end

    context 'with string' do
      let(:domains) { 'www.example.com' }
      it { is_expected.to eq ['www.example.com'] }
    end

    context 'with array' do
      let(:domains) { ['www.example.com', 'www1.example.com'] }
      it { is_expected.to eq ['www.example.com', 'www1.example.com'] }
    end
  end

  describe '#validation_method' do
    subject { cert.validation_method }

    context 'with nil' do
      let(:validation_method) { nil }
      it('returns default') { is_expected.to eq 'http01' }
    end

    context 'with blank' do
      let(:validation_method) { '' }
      it { is_expected.to eq '' }
    end

    context 'with string' do
      let(:validation_method) { 'blahblah' }
      it { is_expected.to eq 'blahblah' }
    end
  end

  describe '#public_dirs' do
    subject { cert.public_dirs }

    context 'with blank' do
      let(:public_dirs) { '' }
      it { is_expected.to eq [] }
    end

    context 'with string' do
      let(:public_dirs) { '~/webapps/myapp/public' }
      it { is_expected.to eq ['~/webapps/myapp/public'] }
    end

    context 'with array' do
      let(:public_dirs) { ['~/webapps/myapp/public', '~/webapps/myapp2'] }
      it { is_expected.to eq ['~/webapps/myapp/public', '~/webapps/myapp2'] }
    end
  end

  describe '#cert_name' do
    subject { cert.cert_name }

    context 'with nil' do
      let(:cert_name) { nil }
      it('returns default') { is_expected.to eq 'www_example_com' }
    end

    context 'with blank' do
      let(:cert_name) { '' }
      it { is_expected.to eq '' }
    end

    context 'with string' do
      let(:cert_name) { 'blahblah' }
      it { is_expected.to eq 'blahblah' }
    end
  end

  describe '#key_size' do
    subject { cert.key_size }

    context 'with nil' do
      let(:key_size) { nil }
      it('returns default') { is_expected.to eq 4096 }
    end

    context 'with integer' do
      let(:key_size) { 1234 }
      it { is_expected.to eq 1234 }
    end
  end

  describe '#errors' do
    subject { cert.errors }

    context 'with valid arguments' do
      it { is_expected.to eq({}) }
    end

    context 'with no domains' do
      let(:domains) { [] }
      it { is_expected.to eq(domains: "can't be empty") }
    end

    context 'with invalid method' do
      let(:validation_method) { 'hello world!' }
      it { is_expected.to eq(method: 'must be "http01"') }
    end

    context 'with no public_dirs' do
      let(:public_dirs) { [] }
      it { is_expected.to eq(public: "can't be empty") }
    end

    context 'with nonexistent public_dirs' do
      it 'returns error'
    end

    context 'with blank cert_name' do
      let(:cert_name) { '' }
      it { is_expected.to eq(name: "can't be blank") }
    end

    context 'with invalid chars in cert_name' do
      let(:cert_name) { '()()()' }
      it { is_expected.to eq(name: 'can only include letters, numbers, and underscores') }
    end

    context 'with invalid key_size' do
      let(:key_size) { 1234 }
      it { is_expected.to eq(key_size: 'must be one of 2048, 4096') }
    end
  end
end
