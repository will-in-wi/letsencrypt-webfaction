require 'pathname'
require 'openssl'

module LetsencryptWebfaction
  module Application
    class Init
      def initialize(_); end

      def run!
        copy_config_file
        create_private_key
        output_next_steps
      end

      private

      def copy_config_file
        source = File.expand_path(File.join(__dir__, '../../../templates/letsencrypt_webfaction.toml'))
        if Pathname.new(Dir.home).join('letsencrypt_webfaction.toml').exist?
          puts 'Config file already exists. Skipping copy...'
        else
          FileUtils.cp(source, Dir.home)
          puts 'Copied configuration file'
        end
      end

      def create_private_key
        # Create config dir.
        config_path = Pathname.new(Dir.home).join('.config', 'letsencrypt_webfaction')
        FileUtils.mkdir_p(config_path)

        key_path = config_path.join('account_key.pem')
        if key_path.exist?
          puts 'Account private key already exists. Skipping generation...'
        else
          # Create private key
          # TODO: Make key size configurable.
          private_key = OpenSSL::PKey::RSA.new(4096)
          config_path.join('account_key.pem').write(private_key.to_pem)
          puts 'Generated and stored account private key'
        end
      end

      def output_next_steps
        puts 'Your system is set up. Next, edit the config file: run `nano ~/letsencrypt_webfaction.yml`.'
      end
    end
  end
end
