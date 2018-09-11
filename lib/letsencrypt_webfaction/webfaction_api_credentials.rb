require 'xmlrpc/client'

module LetsencryptWebfaction
  class WebfactionApiCredentials
    WEBFACTION_API_VERSION = 2

    attr_reader :username
    attr_reader :password
    attr_reader :servername
    attr_reader :api_server

    def initialize(username:, password:, servername:, api_server:)
      @username = username
      @password = password
      @servername = servername
      @api_server = api_server
    end

    def call(action, *args)
      server_client.call(action, session_id, *args)
    end

    def valid?
      !session_id.nil?
    rescue XMLRPC::FaultException => e
      return false if e.message == 'LoginError'

      raise
    end

    private

    def server_client
      @_server_client ||= XMLRPC::Client.new2(api_server)
    end

    def session_id
      @_session_id ||= begin
        login_resp = server_client.call('login', username, password, servername, WEBFACTION_API_VERSION)
        login_resp[0]
      end
    end
  end
end
