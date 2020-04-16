require 'letsencrypt_webfaction/options'
require 'letsencrypt_webfaction/errors'
require 'letsencrypt_webfaction/webfaction_api_credentials'
require 'letsencrypt_webfaction/certificate_issuer'
require 'letsencrypt_webfaction/logger_output'

require 'acme-client'
require 'optparse'
require 'pathname'

module LetsencryptWebfaction
  module Application
    class Run
      RENEWAL_DELTA = 30 # days

      def initialize(args)
        @config_path = DefaultConfigPath.new
        parse_options(args)
        @config_path.validate!

        @options = LetsencryptWebfaction::Options.from_toml(@config_path.path)
      end

      def run!
        validate_options

        # Check credentials
        unless api_credentials.valid?
          $stderr.puts 'WebFaction API username, password, and/or servername are incorrect. Login failed.'
          raise AppExitError, 'WebFaction credentials failed'
        end

        register_key

        process_certs
      end

      private

      class DefaultConfigPath
        attr_reader :path

        def initialize
          @path = Options.default_options_path
        end

        def validate!
          return true if @path.exist?

          print_error
          raise AppExitError, 'config missing'
        end

        private

        def print_error
          $stderr.puts 'The configuration file is missing.'
          $stderr.puts 'You may need to run `letsencrypt_webfaction init`'
        end
      end

      class CustomConfigPath < DefaultConfigPath
        def initialize(path)
          @path = Pathname.new(path)
        end

        private

        def print_error
          $stderr.puts 'The given configuration file does not exist'
        end
      end

      def parse_options(args) # rubocop:disable Metrics/MethodLength
        OptionParser.new do |opts|
          opts.banner = 'Usage: letsencrypt_webfaction run [options]'

          opts.on('--quiet', 'Run with minimal output (useful for cron)') do |q|
            Out.quiet = q
          end

          opts.on('--config=CONFIG', 'Alternative configuration path') do |c|
            @config_path = CustomConfigPath.new(c)
          end

          opts.on('--force', 'When passed, all certs are re-issued regardless of expiration') do |d|
            @force_refresh = d
          end
        end.parse!(args)
      end

      def process_certs # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        wf_cert_list = api_credentials.call('list_certificates')
        @options.certificates.each do |cert|
          wf_cert = wf_cert_list.find { |c| c['name'] == cert.cert_name }
          if @force_refresh
            # Issue because nonexistent
            Out.puts "Force issuing #{cert.cert_name}."
          elsif wf_cert.nil?
            # Issue because nonexistent
            Out.puts "Issuing #{cert.cert_name} for the first time."
          elsif wf_cert['domains'].split(',').map(&:strip).sort == cert.domains.sort
            days_remaining = (Date.parse(wf_cert['expiry_date']) - Date.today).to_i
            if days_remaining < RENEWAL_DELTA
              # Renew because nearing expiration
              Out.puts "#{days_remaining} days until expiration of #{cert.cert_name}. Renewing..."
            else
              # Ignore because active
              Out.puts "#{days_remaining} days until expiration of #{cert.cert_name}. Skipping..."
              next
            end
          else
            # Reissue because different
            Out.puts "Reissuing #{cert.cert_name} due to a change in the domain list."
          end

          CertificateIssuer.new(certificate: cert, api_credentials: api_credentials, client: client).call
        end
      end

      def api_credentials
        @_api_credentials ||= LetsencryptWebfaction::WebfactionApiCredentials.new username: @options.username, password: @options.password, servername: @options.servername, api_server: @options.api_url
      end

      def validate_options # rubocop:disable Metrics/MethodLength
        return if @options.valid?

        $stderr.puts 'The configuration file has an error:'
        @options.errors.each do |field, error|
          case error
          when String
            print_error(field, error)
          when Array
            error.each { |inner_field, inner_err| print_error("#{field} #{inner_field}", inner_err) }
          else
            # :nocov:
            raise 'Unexpected internal error type'
            # :nocov:
          end
        end
        raise AppExitError, 'config invalid'
      end

      def print_error(field, error)
        $stderr.puts "#{field} #{error}"
      end

      def private_key
        @_private_key ||= begin
          key_path = Options.default_config_path.join('account_key.pem')
          unless key_path.exist?
            $stderr.puts 'Account key missing'
            raise AppExitError, 'Account key missing'
          end
          OpenSSL::PKey::RSA.new(Options.default_config_path.join('account_key.pem').read)
        end
      end

      def client
        @_client ||= Acme::Client.new(private_key: private_key, directory: @options.directory)
      end

      def register_key
        return if client.kid

        # If the private key is not known to the server, we need to register it for the first time.
        client.new_account(contact: "mailto:#{@options.letsencrypt_account_email}", terms_of_service_agreed: true)
      end
    end
  end
end
