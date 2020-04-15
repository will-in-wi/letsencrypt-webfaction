require 'letsencrypt_webfaction/application/init'
require 'letsencrypt_webfaction/application/run'
require 'letsencrypt_webfaction/application/version'

module LetsencryptWebfaction
  module Application
    SUPPORTED_COMMANDS = {
      'init' => LetsencryptWebfaction::Application::Init,
      'run' => LetsencryptWebfaction::Application::Run,
      '--version' => LetsencryptWebfaction::Application::Version,
    }.freeze

    V2_COMMANDS = %i[key_size endpoint domains public letsencrypt_account_email api_url username password servername cert_name].freeze

    class << self
      def new(args) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        if args[0].nil?
          $stderr.puts "Missing command. Must be one of #{SUPPORTED_COMMANDS.keys.join(', ')}"
          raise LetsencryptWebfaction::AppExitError, 'Missing command'
        elsif v2_command?(args)
          $stderr.puts 'It looks like you are trying to run a version 2 command in version 4'
          $stderr.puts 'See https://github.com/will-in-wi/letsencrypt-webfaction/blob/master/docs/upgrading.md'
          raise LetsencryptWebfaction::AppExitError, 'v2 command'
        else
          klass = SUPPORTED_COMMANDS[args[0]]
          if klass.nil?
            $stderr.puts "Unsupported command `#{args[0]}`. Must be one of #{SUPPORTED_COMMANDS.keys.join(', ')}"
            raise LetsencryptWebfaction::AppExitError, 'Unsupported command'
          else
            klass.new(args[1..-1])
          end
        end
      end

      private

      def v2_command?(args)
        (args & (V2_COMMANDS.map { |arg| "--#{arg}" })).any?
      end
    end
  end
end
