module LetsencryptWebfaction
  class Instructions
    def initialize(output_dir, domains)
      @output_dir = output_dir
      @domains = domains
    end

    def context(support_email: true)
      out = 'LetsEncrypt Webfaction has generated a new certificate for ' \
        "#{to_sentence @domains}. The certificates have been placed in " \
        "#{@output_dir}. "
      
      if support_email
        out << 'WebFaction support has been contacted with the following message:'
      else
        out << 'Go to https://help.webfaction.com, log in, and paste the ' \
        'following text into a new ticket:'
      end

      out
    end

    def instructions
      "Please apply the new certificate in #{@output_dir} to " \
      "#{to_sentence @domains}. Thanks!"
    end

    def full_message(support_email: true)
      context(support_email: support_email) + "\n\n" + instructions
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
