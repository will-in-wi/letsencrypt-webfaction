module LetsencryptWebfaction
  class WebfactionApiCredentials
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
  end
end
