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
      # Save the certificate and key

      server = XMLRPC::Client.new2(@credentials.api_server)
      login_resp = server.call('login', @credentials.username, @credentials.password, @credentials.servername, WEBFACTION_API_VERSION)
      session_id = login_resp[0]

      cert_list = server.call('list_certificates', session_id)
      action = if cert_list.find { |cert| cert['name'] == @cert_name }
        'update_certificate'
      else
        'create_certificate'
      end
      server.call(action, session_id, @cert_name, @certificate.to_pem, @certificate.request.private_key.to_pem, @certificate.chain_to_pem)

      true
    end
  end
end
