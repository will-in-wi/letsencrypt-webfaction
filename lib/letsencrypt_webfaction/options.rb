require 'toml-rb'
require 'socket'

require 'letsencrypt_webfaction/options/certificate'

module LetsencryptWebfaction
  class Options
    NON_BLANK_FIELDS = %i[username password letsencrypt_account_email v2_endpoint api_url servername].freeze

    WEBFACTION_API_URL = 'https://api.webfaction.com/'.freeze

    def initialize(args)
      @config = args
      # Fetch options
      # Validate options
    end

    def self.from_toml(path)
      new TomlRB.parse(path.read)
    end

    def self.default_options_path
      Pathname.new(Dir.home).join('letsencrypt_webfaction.toml')
    end

    def self.default_config_path
      Pathname.new(Dir.home).join('.config', 'letsencrypt_webfaction')
    end

    def username
      @config['username']
    end

    def password
      @config['password']
    end

    def letsencrypt_account_email
      @config['letsencrypt_account_email']
    end

    def v2_endpoint
      @config['v2_endpoint']
    end

    def api_url
      @config['api_url'] || WEBFACTION_API_URL
    end

    def servername
      @config['servername'] || Socket.gethostname.split('.')[0].sub(/^./, &:upcase)
    end

    def certificates
      @_certs ||= @config['certificate'].map { |cert| Certificate.new(cert) }
    end

    def errors
      {}.tap do |e|
        e[:endpoint] = 'needs to be updated to v2_endpoint. See upgrade documentation.' if @config.key?('endpoint')
        NON_BLANK_FIELDS.each do |field|
          e[field] = "can't be blank" if public_send(field).nil? || public_send(field) == ''
        end
        cert_errors = certificates.map(&:errors).reject(&:empty?)
        e[:certificate] = cert_errors if cert_errors.any?
      end
    end

    def valid?
      errors.none?
    end
  end
end
