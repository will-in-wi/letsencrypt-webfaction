require 'pony'

module LetsencryptWebfaction
  class Emailer
    SUBJECT_MESSAGE = 'New certificate installation'.freeze

    def initialize(instructions, support_email: '', account_email: '', notification_email: '')
      @instructions = instructions

      raise Error, 'Missing account_email' if account_email == '' || account_email.nil?
      raise Error, 'Missing notification_email' if notification_email == '' || notification_email.nil?

      @support_email = support_email
      @account_email = account_email
      @notification_email = notification_email
    end

    def send!
      send_to_support!
      send_to_account!
    end

    def send_to_support!
      return if @support_email.nil? || @support_email == ''
      Pony.mail(to: @support_email, from: @account_email, subject: SUBJECT_MESSAGE, body: @instructions.full_message(support_email: @support_email != ''))
    end

    def send_to_account!
      Pony.mail(to: @notification_email, from: @notification_email, subject: SUBJECT_MESSAGE, body: @instructions.full_message(support_email: @support_email != ''))
    end

    class Error < StandardError; end
  end
end
