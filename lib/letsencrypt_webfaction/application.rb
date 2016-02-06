require 'openssl'
require 'acme/client'

require 'letsencrypt_webfaction/args_parser'
require 'letsencrypt_webfaction/domain_validator'
require 'letsencrypt_webfaction/certificate_writer'
require 'letsencrypt_webfaction/instructions'

module LetsencryptWebfaction
  class Application
    def initialize
      @options = LetsencryptWebfaction::ArgsParser.new(ARGV)
    end

    def run!
      # Validate that the correct options were passed.
      validate_options!

      # Register the private key.
      register_key!

      # Validate the domains.
      validator.validate!

      # Write the obtained certificates.
      certificate_writer.write!

      # Dump help text.
      puts instructions.message
    end

    private

    def instructions
      @instructions ||= LetsencryptWebfaction::Instructions.new certificate_writer.output_dir, @options.domains
    end

    def certificate_writer
      @certificate_writer ||= LetsencryptWebfaction::CertificateWriter.new(@options.output_dir, @options.domains.first, certificate)
    end

    def certificate
      # We can now request a certificate, you can pass anything that returns
      # a valid DER encoded CSR when calling to_der on it, for example a
      # OpenSSL::X509::Request too.
      @certificate ||= client.new_certificate(csr)
    end

    def csr
      # We're going to need a certificate signing request. If not explicitly
      # specified, the first name listed becomes the common name.
      @csr ||= Acme::Client::CertificateRequest.new(names: @options.domains)
    end

    def validator
      @validator ||= LetsencryptWebfaction::DomainValidator.new @options.domains, client, @options.public
    end

    def client
      @client ||= Acme::Client.new(private_key: private_key, endpoint: @options.endpoint)
    end

    def register_key!
      # If the private key is not known to the server, we need to register it for the first time.
      registration = client.register(contact: "mailto:#{@options.contact}")

      # You'll may need to agree to the term (that's up the to the server to require it or not but boulder does by default)
      registration.agree_terms
    end

    def validate_options!
      return if options.valid?
      puts options.errors.values.join("\n")
      exit
    end

    def private_key
      OpenSSL::PKey::RSA.new(@options.key_size)
    end
  end
end
