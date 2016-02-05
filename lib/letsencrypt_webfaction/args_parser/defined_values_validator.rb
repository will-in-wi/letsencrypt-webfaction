module LetsencryptWebfaction
  class ArgsParser
    class DefinedValuesValidator
      def initialize(values = [])
        @values = values
      end

      def valid?(val)
        @values.include? val
      end
    end
  end
end
