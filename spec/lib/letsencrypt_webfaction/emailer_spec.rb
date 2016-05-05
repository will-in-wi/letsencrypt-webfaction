require 'letsencrypt_webfaction/emailer'
require 'letsencrypt_webfaction/instructions'

RSpec.describe LetsencryptWebfaction::Emailer do
  let(:notification_email) { 'notifyme@example.com' }
  let(:account_email) { 'me@example.com' }
  let(:support_email) { 'support@example.com' }
  let(:instructions) { LetsencryptWebfaction::Instructions.new 'outdir', ['www.example.com'] }
  let(:email_configuration) { {} }
  let(:emailer) { LetsencryptWebfaction::Emailer.new instructions, support_email: support_email, account_email: account_email, notification_email: notification_email, email_configuration: email_configuration }
  let(:emails) { Mail::TestMailer.deliveries }

  describe '#send!' do
    before :each do
      Mail::TestMailer.deliveries.clear

      emailer.send!
    end

    it 'sends two emails' do
      expect(Mail::TestMailer.deliveries.length).to eq 2
    end

    context 'with special configuration' do
      let(:email_configuration) { { headers: { 'X-Custom-Header' => 'Testing 1.2.3...' } } }

      it 'has the passed header' do
        expect(emails.first['X-Custom-Header'].to_s).to eq 'Testing 1.2.3...'
      end
    end

    context 'email to support' do
      subject do
        emails.find { |e| e.to.include? support_email }
      end

      it 'has one such email' do
        expect(subject.to).to include support_email
      end

      it 'has the correct message' do
        expect(subject.body).to include 'Please apply the new certificate'
      end

      it 'does not have wrapper' do
        expect(subject.body).to_not include 'WebFaction support has been contacted'
      end

      it 'has the correct from' do
        expect(subject.from).to include account_email
      end
    end

    context 'email to notification address' do
      subject do
        emails.find { |e| e.to.include? notification_email }
      end

      it 'has one such email' do
        expect(subject.to).to include notification_email
      end

      it 'has the correct message' do
        expect(subject.body).to include 'Please apply the new certificate'
      end

      it 'has not sent to support' do
        expect(subject.body).to include 'WebFaction support has been contacted'
        expect(subject.body).to_not include 'paste the following text into a new ticket'
      end
    end

    context 'with no support_email' do
      let(:support_email) { '' }

      it 'only sends one email' do
        expect(Mail::TestMailer.deliveries.length).to eq 1
      end

      it 'sends the account email' do
        expect(emails.first.to).to include notification_email
        expect(emails.first.to.size).to eq 1
      end

      it 'has not sent to support' do
        expect(emails.first.body).to_not include 'WebFaction support has been contacted'
        expect(emails.first.body).to include 'paste the following text into a new ticket'
      end
    end
  end
end
