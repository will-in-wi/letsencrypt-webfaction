require 'letsencrypt_webfaction/application/init'
require 'letsencrypt_webfaction/application/run'

module LetsencryptWebfaction
  module Application
    SUPPORTED_COMMANDS = {
      'init' => LetsencryptWebfaction::Application::Init,
      'run' => LetsencryptWebfaction::Application::Run,
    }.freeze

    def self.new(args)
      if args[0].nil?
        $stderr.puts "Missing command. Must be one of #{SUPPORTED_COMMANDS.keys.join(', ')}"
        raise LetsencryptWebfaction::AppExitError, 'Missing command'
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
  end
end
