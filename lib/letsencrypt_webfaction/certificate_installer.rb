require 'xmlrpc/client'

module LetsencryptWebfaction
  class CertificateInstaller
    WEBFACTION_API_VERSION = 2

    def initialize(cert_name, certificate, credentials)
      @cert_name = cert_name
      @certificate = certificate
      @credentials = credentials
    end

    def install!
      cert_list = @credentials.call('list_certificates')
      action = if cert_list.find { |cert| cert['name'] == @cert_name }
                 'update_certificate'
               else
                 'create_certificate'
               end
      @credentials.call(action, @cert_name, @certificate.to_pem, @certificate.request.private_key.to_pem, @certificate.chain_to_pem)

      true
    end
  end
end
