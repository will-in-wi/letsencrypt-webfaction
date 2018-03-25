require 'optparse'
require 'socket'
require 'yaml'

require 'letsencrypt_webfaction'
require 'letsencrypt_webfaction/args_parser/field'
require 'letsencrypt_webfaction/args_parser/string_validator'
require 'letsencrypt_webfaction/args_parser/defined_values_validator'
require 'letsencrypt_webfaction/args_parser/array_validator'

module LetsencryptWebfaction
  class ArgsParser
    BANNER = 'Usage: letsencrypt_webfaction [options]'.freeze
    DEFAULTS_PATH = 'config.defaults.yml'.freeze
    VALID_KEY_SIZES = [2048, 4096].freeze

    FIELDS = [
      Field::IntegerField.new(:key_size, 'Size of private key (e.g. 4096)', [DefinedValuesValidator.new(VALID_KEY_SIZES)]),
      Field.new(:endpoint, 'ACME endpoint (e.g. https://acme-v01.api.letsencrypt.org/)', [StringValidator.new]),
      Field::ListField.new(:domains, 'Comma separated list of domains. The first one will be the common name.', [ArrayValidator.new]),
      Field::ListField.new(:public, 'Locations on the filesystem served by the desired sites (e.g. "~/webapps/myapp/public_html,~/webapps/myapp1/public_html")', [ArrayValidator.new]),
      Field.new(:letsencrypt_account_email, 'The email address associated with your account.', [StringValidator.new]),
      Field.new(:api_url, 'The URL to the Webfaction API.', [StringValidator.new]),
      Field.new(:username, 'The username for your Webfaction account.', [StringValidator.new]),
      Field.new(:password, 'The password for your Webfaction account.', [StringValidator.new]),
      Field.new(:servername, 'The server on which this application resides (e.g. Web123).', [StringValidator.new]),
      Field.new(:cert_name, 'The name of the certificate in the Webfaction UI.', [StringValidator.new]),
      Field::BooleanField.new(:quiet, 'Whether to display text on success.', []),
    ].freeze

    # Set up getters.
    FIELDS.map(&:identifier).each do |field|
      attr_reader field
    end

    # Set up boolean getters
    FIELDS.reject(&:value?).map(&:identifier).each do |field|
      define_method "#{field}?" do
        instance_variable_get("@#{field}") || false
      end
    end

    # EMail config is special, as it only comes from the config file, due to complexity.
    attr_reader :email_configuration

    def initialize(options)
      @options = options

      @errors = {}

      # Set defaults from default config file.
      file_path = File.join(File.dirname(__FILE__), '../../', DEFAULTS_PATH)
      load_config!(File.expand_path(file_path))

      # TODO: Rework this to not exit on instantiation due to help text or version.
      parse!
    end

    def errors
      errors = {}

      FIELDS.each do |field|
        val = instance_variable_get("@#{field.identifier}")
        next if field.valid? val
        errors[field.identifier] ||= []
        errors[field.identifier] << "Invalid #{field.identifier} '#{val}'"
      end

      errors
    end

    def valid?
      errors.empty?
    end

    private

    def load_config!(config_path)
      config = YAML.load_file(config_path)
      FIELDS.each do |field|
        next unless config[field.identifier.to_s]
        instance_variable_set("@#{field.identifier}", field.sanitize(config[field.identifier.to_s]))
      end

      @email_configuration = config['email_configuration'] || {}
    end

    def handle_config(opts)
      opts.on('--config=CONFIG', 'Path to config file. Arguments passed to the program will override corresponding directives in the config file.') do |c|
        # Set defaults.
        load_config!(c)
      end
    end

    def handle_help(opts)
      opts.on('-h', '--help', 'Prints this help') do
        puts opts
        exit
      end
    end

    def handle_version(opts)
      opts.on_tail('--version', 'Show version') do
        puts LetsencryptWebfaction::VERSION
        exit
      end
    end

    def handle_field(opts, field)
      argument = "--#{field.identifier}"
      argument += "=#{field.identifier.upcase}" if field.value?
      opts.on(argument, field.description) do |val|
        instance_variable_set("@#{field.identifier}", field.sanitize(val))
      end
    end

    def opt_parser
      OptionParser.new do |opts|
        opts.banner = BANNER

        handle_config(opts)
        handle_help(opts)
        handle_version(opts)
        FIELDS.each { |field| handle_field(opts, field) }
      end
    end

    def parse!
      opt_parser.parse!(@options)

      # Set default hostname
      if @servername.nil? || @servername == ''
        @servername = Socket.gethostname.split('.')[0].sub(/^./, &:upcase)
      end

      # Set default cert_name
      if @cert_name.nil? || @cert_name == ''
        @cert_name = @domains[0] if @domains.any?
      end
      @cert_name = @cert_name.gsub(/[^a-zA-Z\d_]/, '_')
    end
  end
end
