require 'fileutils'
require 'pry'

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

      i = 0
      until all_challenges_valid? || i == 10
        # Wait a bit for the server to make the request, or really just blink, it should be fast.
        sleep(1)

        i += 1
      end

      unless all_challenges_valid?
        validations = authorizations.map(&:domain).zip(challenges)
        $stderr.puts 'Failed to verify statuses.'
        validations.each do |tuple|
          domain, challenge = tuple
          if challenge.verify_status == 'valid'
            $stderr.puts "#{domain}: Success"
          else
            $stderr.puts "#{domain}: #{challenge.error['detail']}"
            $stderr.puts "Make sure that you can access http://#{domain}/#{challenge.filename}"
          end
        end

        return false
      end

      true
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
  end
end
