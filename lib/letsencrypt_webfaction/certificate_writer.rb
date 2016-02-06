module LetsencryptWebfaction
  class CertificateWriter
    attr_reader :output_dir

    def initialize(output_dir, domain, certificate)
      @certificate = certificate

      cert_date = Time.now.strftime('%Y%m%d%H%M%S')

      expanded_dir = File.expand_path(output_dir)
      @output_dir = File.join(expanded_dir, domain, cert_date)
    end

    def write!
      create_folder!

      # Save the certificate and key
      write_file!('privkey.pem', @certificate.request.private_key.to_pem)
      write_file!('cert.pem', @certificate.to_pem)
      write_file!('chain.pem', @certificate.chain_to_pem)
      write_file!('fullchain.pem', @certificate.fullchain_to_pem)
    end

    private

    def create_folder!
      # Make sure the output directory exists.
      FileUtils.mkdir_p(output_dir)
    end

    def write_file!(filename, data)
      File.write(File.join(@output_dir, filename), data)
    end
  end
end
