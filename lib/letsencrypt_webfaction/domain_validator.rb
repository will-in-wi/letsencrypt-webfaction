module LetsencryptWebfaction
  class DomainValidator
    def initialize(domains, client)
      @domains = domains
      @client = client
    end

    def validate!
      write_files!

      challenges.each(&:request_verification)

      i = 0
      until all_challenges_valid? || i == 10
        # Wait a bit for the server to make the request, or really just blink, it should be fast.
        sleep(1)

        puts 'pending'
        i += 1
      end

      raise 'Failed to verify statuses in 10 seconds.' unless all_challenges_valid?
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
        FileUtils.mkdir_p(File.join(@options.public, File.dirname(challenge.filename)))

        # Then writing the file
        File.write(File.join(@options.public, challenge.filename), challenge.file_content)
      end
    end

    def delete_files!
      # TODO
    end
  end
end
