require 'acme-client'
require 'letsencrypt_webfaction/domain_validator'
require 'letsencrypt_webfaction/certificate_installer'

module LetsencryptWebfaction
  class CertificateIssuer
    def initialize(certificate:, api_credentials:, client:)
      @cert_config = certificate
      @api_credentials = api_credentials
      @client = client
    end

    def call
      # Validate the domains.
      return unless validator.validate!

      # Write the obtained certificates.
      certificate_installer.install!

      output_success_help
    end

    private

    def order
      @_order ||= @client.new_order(identifiers: @cert_config.domains)
    end

    def validator
      @_validator ||= LetsencryptWebfaction::DomainValidator.new order, @client, @cert_config.public_dirs
    end

    def certificate_installer
      @_certificate_installer ||= LetsencryptWebfaction::CertificateInstaller.new(@cert_config.cert_name, certificate, @api_credentials)
    end

    def certificate
      # We can now request a certificate, you can pass anything that returns
      # a valid DER encoded CSR when calling to_der on it, for example a
      # OpenSSL::X509::Request too.
      @_certificate ||= begin
        order.finalize(csr: csr)
        while order.status == 'processing'
          sleep(2)
          order.reload
        end

        order.certificate
      end
    end

    def csr
      # We're going to need a certificate signing request. If not explicitly
      # specified, the first name listed becomes the common name.
      @_csr ||= Acme::Client::CertificateRequest.new(names: @cert_config.domains)
    end

    def output_success_help
      Out.puts 'Your new certificate is now created and installed.'
      Out.puts "You will need to change your application to use the #{@cert_config.cert_name} certificate."
      Out.puts 'Add the `--quiet` parameter in your cron task to remove this message.'
    end
  end
end
