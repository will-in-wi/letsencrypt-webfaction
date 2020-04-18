# frozen_string_literal: true

module LetsencryptWebfaction
  class Error < StandardError; end
  class InvalidConfigValueError < Error; end
  class AppExitError < Error; end
end
