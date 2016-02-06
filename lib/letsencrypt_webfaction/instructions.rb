module LetsencryptWebfaction
  class Instructions
    def initialize(output_dir, domains)
      @output_dir = output_dir
      @domains = domains
    end

    def message
      'LetsEncrypt Webfaction has generated a new certificate for ' \
      "#{to_sentence @domains}. The certificates have been placed in " \
      "#{@output_dir}. You now need to request installation from the " \
      "WebFaction support team.\n\n" \
      'Go to https://help.webfaction.com, log in, and paste the ' \
      "following text into a new ticket:\n\n" \
      "Please apply the new certificate in #{@output_dir} to " \
      "#{to_sentence @domains}. Thanks!"
    end

    private

    # Borrowed (with simplifications) from ActiveSupport.
    def to_sentence(str)
      case str.length
      when 0
        ''
      when 1
        str[0].to_s.dup
      when 2
        "#{str[0]} and #{str[1]}"
      else
        "#{str[0...-1].join(', ')}, and #{str[-1]}"
      end
    end
  end
end
