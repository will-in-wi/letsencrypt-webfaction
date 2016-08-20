require 'fileutils'

module LetsencryptWebfaction
  class DomainValidator
    def initialize(domains, client, public_dir)
      @domains = domains
      @client = client
      @public_dir = File.expand_path(public_dir)
    end

    def validate!
      write_files!

      challenges.each(&:request_verification)

      10.times do
        return true if all_challenges_valid?
        sleep(1)
      end

      print_errors
      false
    end

    private

    def authorizations
      @domains.map { |domain| @client.authorize(domain: domain) }
    end

    def challenges
      @challenges ||= authorizations.map(&:http01)
    end

    def all_challenges_valid?
      challenges.reject { |challenge| challenge.verify_status == 'valid' }.empty?
    end

    def write_files!
      challenges.each do |challenge|
        # Save the file. We'll create a public directory to serve it from, and we'll creating the challenge directory.
        FileUtils.mkdir_p(File.join(@public_dir, File.dirname(challenge.filename)))

        # Then writing the file
        File.write(File.join(@public_dir, challenge.filename), challenge.file_content)
      end
    end

    def print_errors
      validations = authorizations.map(&:domain).zip(challenges)
      $stderr.puts 'Failed to verify statuses.'
      validations.each { |tuple| Validation.new(*tuple).print_error }
    end

    class Validation
      def initialize(domain, challenge)
        @domain = domain
        @challenge = challenge
      end

      def print_error
        if @challenge.verify_status == 'valid'
          $stderr.puts "#{@domain}: Success"
        else
          $stderr.puts "#{@domain}: #{@challenge.error['detail']}"
          $stderr.puts "Make sure that you can access #{url}"
        end
      end

      def url
        "http://#{@domain}/#{@challenge.filename}"
      end
    end
  end
end
