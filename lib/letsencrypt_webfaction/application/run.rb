require 'letsencrypt_webfaction/options'
require 'letsencrypt_webfaction/errors'
require 'letsencrypt_webfaction/webfaction_api_credentials'
require 'letsencrypt_webfaction/certificate_issuer'

require 'acme-client'

module LetsencryptWebfaction
  module Application
    class Run
      RENEWAL_DELTA = 14 # days

      def initialize(_args)
        # TODO: args should be supported: --quiet --config
        unless Options.default_options_path.exist?
          $stderr.puts 'The configuration file is missing.'
          $stderr.puts 'You may need to run `letsencrypt_webfaction init`'
          raise AppExitError, 'config missing'
        end
        @options = LetsencryptWebfaction::Options.from_toml(Options.default_options_path)
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

      def process_certs # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        wf_cert_list = api_credentials.call('list_certificates')
        @options.certificates.each do |cert|
          wf_cert = wf_cert_list.find { |c| c['name'] == cert.cert_name }
          if wf_cert.nil?
            # Issue because nonexistent
            puts "Issuing #{cert.cert_name} for the first time."
          elsif wf_cert['domains'].sort == cert.domains.sort
            days_remaining = (Date.parse(wf_cert['expiry_date']) - Date.now)
            if days_remaining < RENEWAL_DELTA
              # Renew because nearing expiration
              puts "#{days_remaining} days until expiration of #{cert.cert_name}. Renewing..."
            else
              # Ignore because active
              puts "#{days_remaining} days until expiration of #{cert.cert_name}. Skipping..."
              next
            end
          else
            # Reissue because different
            puts "Reissuing #{cert.cert_name} due to a change in the domain list."
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
            raise 'Unexpected internal error type'
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
        @_client ||= Acme::Client.new(private_key: private_key, endpoint: @options.endpoint)
      end

      def register_key
        # If the private key is not known to the server, we need to register it for the first time.
        registration = client.register(contact: "mailto:#{@options.letsencrypt_account_email}")

        # You'll may need to agree to the term (that's up the to the server to require it or not but boulder does by default)
        registration.agree_terms
      rescue Acme::Client::Error::Malformed => e
        # Stupid hack if the registration already exists.
        return if e.message == 'Registration key is already in use'
        raise
      end
    end
  end
end
