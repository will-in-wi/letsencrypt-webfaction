module LetsencryptWebfaction
  class ArgsParser
    class Field
      attr_reader :identifier, :description, :validators

      def initialize(identifier, description, validators = [])
        @identifier = identifier
        @description = description
        @validators = validators
      end

      def sanitize(val)
        val
      end

      def valid?(val)
        validators.reject { |validator| validator.valid?(val) }.empty?
      end

      def value?
        true
      end

      class IntegerField < Field
        def sanitize(val)
          val.to_i
        end
      end

      class ListField < Field
        def sanitize(val)
          return val if val.is_a?(Array)
          val.split(',').map(&:strip).compact
        end
      end

      class BooleanField < Field
        def sanitize(val)
          val || false
        end

        def value?
          false
        end
      end
    end
  end
end
