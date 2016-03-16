require 'letsencrypt_webfaction/emailer'

RSpec.describe LetsencryptWebfaction::Emailer do
  let(:account_email) { 'me@example.com' }
  let(:support_email) { 'support@example.com' }
  let(:instructions) do
    inst = instance_double 'LetsencryptWebfaction::Instructions'
    allow(inst).to receive(:full_message).with(any_args).and_return('WOOHOO!')
    inst
  end
  let(:emailer) { LetsencryptWebfaction::Emailer.new instructions, support_email: support_email, account_email: account_email }
  let(:emails) { Mail::TestMailer.deliveries }

  describe '#send!' do
    before :each do
      Mail::TestMailer.deliveries.clear

      emailer.send!
    end

    it 'sends two emails' do
      expect(Mail::TestMailer.deliveries.length).to eq 2
    end

    context 'email to support' do
      subject do
        emails.find { |e| e.to.include? support_email }
      end

      it 'has one such email' do
        expect(subject.to).to include support_email
      end

      it 'has the correct message' do
        expect(subject.body).to include 'WOOHOO!'
      end
    end

    context 'email to account address' do
      subject do
        emails.find { |e| e.to.include? account_email }
      end

      it 'has one such email' do
        expect(subject.to).to include account_email
      end

      it 'has the correct message' do
        expect(subject.body).to include 'WOOHOO!'
      end
    end

    context 'with no support_email' do
      let(:support_email) { '' }

      it 'only sends one email' do
        expect(Mail::TestMailer.deliveries.length).to eq 1
      end

      it 'sends the account email' do
        expect(emails.first.to).to include account_email
        expect(emails.first.to.size).to eq 1
      end
    end
  end
end
