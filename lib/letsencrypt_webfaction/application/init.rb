require 'letsencrypt_webfaction/options'

require 'pathname'
require 'fileutils'
require 'openssl'

module LetsencryptWebfaction
  module Application
    class Init
      def initialize(_); end # rubocop:disable Naming/UncommunicativeMethodParamName

      def run!
        copy_config_file
        create_private_key
        output_next_steps
        # TODO: Create crontab entry
        # TODO: Make sure that configuration file has a "this has been configured" flag
        # TODO: Add a bash binary type thingy
        # TODO: Add an installer command?
      end

      private

      def copy_config_file
        source = File.expand_path(File.join(__dir__, '../../../templates/letsencrypt_webfaction.toml'))
        if Options.default_options_path.exist?
          puts 'Config file already exists. Skipping copy...'
        else
          FileUtils.cp(source, Dir.home)
          puts 'Copied configuration file'
        end
      end

      def create_private_key
        # Create config dir.
        FileUtils.mkdir_p(Options.default_config_path)

        key_path = Options.default_config_path.join('account_key.pem')
        if key_path.exist?
          puts 'Account private key already exists. Skipping generation...'
        else
          # Create private key
          # TODO: Make key size configurable.
          private_key = OpenSSL::PKey::RSA.new(4096)
          Options.default_config_path.join('account_key.pem').write(private_key.to_pem)
          puts 'Generated and stored account private key'
        end
      end

      def output_next_steps
        puts 'Your system is set up. Next, edit the config file: run `nano ~/letsencrypt_webfaction.toml`.'
      end
    end
  end
end
