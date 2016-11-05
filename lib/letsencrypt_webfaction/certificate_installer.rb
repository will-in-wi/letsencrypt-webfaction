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
      cert_list = server_client.call('list_certificates', session_id)
      action = if cert_list.find { |cert| cert['name'] == @cert_name }
                 'update_certificate'
               else
                 'create_certificate'
               end
      server_client.call(action, session_id, @cert_name, @certificate.to_pem, @certificate.request.private_key.to_pem, @certificate.chain_to_pem)

      true
    end

    private

    def server_client
      @server_client ||= XMLRPC::Client.new2(@credentials.api_server)
    end

    def session_id
      @session_id ||= begin
        login_resp = server_client.call('login', @credentials.username, @credentials.password, @credentials.servername, WEBFACTION_API_VERSION)
        login_resp[0]
      end
    end
  end
end
