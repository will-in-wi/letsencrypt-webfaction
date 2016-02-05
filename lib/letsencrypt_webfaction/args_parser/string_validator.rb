module LetsencryptWebfaction
  class ArgsParser
    class StringValidator
      def valid?(val)
        !val.nil? && val != ''
      end
    end
  end
end
