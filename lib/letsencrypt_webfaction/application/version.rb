require 'letsencrypt_webfaction'

module LetsencryptWebfaction
  module Application
    class Version
      def initialize(_); end

      def run!
        puts LetsencryptWebfaction::VERSION
      end
    end
  end
end
