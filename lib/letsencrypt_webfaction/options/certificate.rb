module LetsencryptWebfaction
  class Options
    class Certificate
      SUPPORTED_VALIDATION_METHODS = ['http01'].freeze
      VALID_CERT_NAME = /[^a-zA-Z\d_]/
      VALID_KEY_SIZES = [2048, 4096].freeze

      def initialize(args)
        @args = args
      end

      def domains
        return [] if @args['domains'].nil? || @args['domains'] == ''
        Array(@args['domains'])
      end

      def validation_method
        @args['method'] || 'http01'
      end

      def public_dirs
        return [] if @args['public'].nil? || @args['public'] == ''
        Array(@args['public'])
      end

      def cert_name
        if @args['name'].nil? && domains.any?
          domains[0].gsub(VALID_CERT_NAME, '_')
        else
          @args['name']
        end
      end

      def key_size
        @args['key_size'] || 4096
      end

      def errors # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        {}.tap do |e|
          e[:domains] = "can't be empty" if domains.none?
          e[:method] = 'must be "http01"' unless SUPPORTED_VALIDATION_METHODS.include?(validation_method)
          e[:public] = "can't be empty" if public_dirs.none?
          e[:name] = "can't be blank" if cert_name.nil? || cert_name == ''
          e[:name] = 'can only include letters, numbers, and underscores' if cert_name =~ VALID_CERT_NAME
          e[:key_size] = "must be one of #{VALID_KEY_SIZES.join(', ')}" unless VALID_KEY_SIZES.include?(key_size)
        end
      end
    end
  end
end
