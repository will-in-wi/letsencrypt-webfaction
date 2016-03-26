require 'optparse'
require 'yaml'

require 'letsencrypt_webfaction/args_parser/field'
require 'letsencrypt_webfaction/args_parser/string_validator'
require 'letsencrypt_webfaction/args_parser/defined_values_validator'
require 'letsencrypt_webfaction/args_parser/array_validator'

module LetsencryptWebfaction
  class ArgsParser
    BANNER = 'Usage: get_cert [options]'.freeze
    DEFAULTS_PATH = 'config.defaults.yml'.freeze
    VALID_KEY_SIZES = [2048, 4096].freeze

    FIELDS = [
      Field::IntegerField.new(:key_size, 'Size of private key (e.g. 4096)', [DefinedValuesValidator.new(VALID_KEY_SIZES)]),
      Field.new(:endpoint, 'ACME endpoint (e.g. https://acme-v01.api.letsencrypt.org/)', [StringValidator.new]),
      Field.new(:contact, 'Email address to notify on renewal', [StringValidator.new]),
      Field::ListField.new(:domains, 'Comma separated list of domains. The first one will be the common name.', [ArrayValidator.new]),
      Field.new(:public, 'Location on the filesystem served by the desired site (e.g. ~/webapps/myapp/public_html)', [StringValidator.new]),
      Field.new(:output_dir, 'Location on the filesystem to which the certs will be saved.', [StringValidator.new]),
      Field.new(:support_email, 'The email address of the support company.', []),
      Field.new(:account_email, 'The email address associated with your account. Defaults to the value of contact.', []),
    ].freeze

    # Set up getters.
    FIELDS.map(&:identifier).each do |field|
      attr_reader field
    end

    def initialize(options)
      @options = options

      @errors = {}

      # Set defaults from default config file.
      file_path = File.join(File.dirname(__FILE__), '../../', DEFAULTS_PATH)
      load_config!(File.expand_path(file_path))

      # TODO: Rework this to not exit on instantiation due to help text.
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
        instance_variable_set("@#{field.identifier}", config[field.identifier.to_s])
      end
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

    def handle_field(opts, field)
      opts.on("--#{field.identifier}=#{field.identifier.upcase}", field.description) do |val|
        instance_variable_set("@#{field.identifier}", field.sanitize(val))
      end
    end

    def opt_parser
      OptionParser.new do |opts|
        opts.banner = BANNER

        handle_config(opts)
        handle_help(opts)
        FIELDS.each { |field| handle_field(opts, field) }
      end
    end

    def parse!
      opt_parser.parse!(@options)
    end
  end
end
