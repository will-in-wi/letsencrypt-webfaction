module LetsencryptWebfaction
  class ArgsParser
    class ArrayValidator
      def valid?(val)
        !val.nil? && !val.empty?
      end
    end
  end
end
