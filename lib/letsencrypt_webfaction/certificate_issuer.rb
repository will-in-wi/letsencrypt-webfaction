module LetsencryptWebfaction
  class CertificateIssuer
    def initialize(certificate:, api_credentials:, client:)
      @cert_config = certificate
      @api_credentials = api_credentials
      @client = client
    end

    def call
      # TODO: Figure out if I need to renew/issue the cert.

      # Validate the domains.
      return unless validator.validate!

      # Write the obtained certificates.
      certificate_installer.install!

      output_success_help
    end

    private

    def validator
      @_validator ||= LetsencryptWebfaction::DomainValidator.new @cert_config.domains, @client, @cert_config.public
    end

    def certificate_installer
      @_certificate_installer ||= LetsencryptWebfaction::CertificateInstaller.new(@cert_config.cert_name, certificate, @api_credentials)
    end

    def certificate
      # We can now request a certificate, you can pass anything that returns
      # a valid DER encoded CSR when calling to_der on it, for example a
      # OpenSSL::X509::Request too.
      @_certificate ||= @client.new_certificate(csr)
    end

    def csr
      # We're going to need a certificate signing request. If not explicitly
      # specified, the first name listed becomes the common name.
      @_csr ||= Acme::Client::CertificateRequest.new(names: @cert_config.domains)
    end

    def output_success_help
      # TODO: Handle quiet
      puts 'Your new certificate is now created and installed.'
      puts "You will need to change your application to use the #{@cert_config.cert_name} certificate."
      # puts 'Add the `--quiet` parameter in your cron task to remove this message.'
    end
  end
end
