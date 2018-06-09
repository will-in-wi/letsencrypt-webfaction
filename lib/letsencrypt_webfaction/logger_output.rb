module LetsencryptWebfaction
  class LoggerOutput
    attr_accessor :quiet
    def initialize(quiet: false)
      @quiet = quiet
    end

    def puts(msg)
      Kernel.puts msg unless @quiet
    end
  end

  Out = LoggerOutput.new
end
