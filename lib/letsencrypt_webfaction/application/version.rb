module LetsencryptWebfaction
  module Application
    class Version
      def initialize(_); end # rubocop:disable Naming/UncommunicativeMethodParamName

      def run!
        puts LetsencryptWebfaction::VERSION
      end
    end
  end
end
