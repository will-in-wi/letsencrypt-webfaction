# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'letsencrypt_webfaction'

Gem::Specification.new do |spec|
  spec.name          = 'letsencrypt_webfaction'
  spec.version       = LetsencryptWebfaction::VERSION
  spec.authors       = ['William Johnston']
  spec.email         = ['william@johnstonhaus.us']

  spec.summary       = 'LetsEncrypt utility client for WebFaction hosts.'
  spec.description   = 'A tool to simplify the manual process of using ' \
                       'LetsEncrypt on Webfaction hosts. It can be added to ' \
                       'cron where it will validate your domains ' \
                       'automatically, place the generated certs in a common ' \
                       'folder, and then email the WebFaction support team directions'
  spec.homepage      = 'https://github.com/will-in-wi/letsencrypt-webfaction'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w(lib)

  spec.cert_chain  = ['certs/will_in_wi.pem']
  spec.signing_key = File.expand_path('~/.ssh/gem-private_key.pem') if $PROGRAM_NAME.end_with?('gem')

  spec.required_ruby_version = '>= 2.1.0'

  spec.add_runtime_dependency 'acme-client', '>=0.4.1'
  spec.add_runtime_dependency 'pony', '~> 1.11'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'rubocop', '~> 0.37'
  spec.add_development_dependency 'simplecov', '~> 0.11'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'pry-byebug', '~> 3.3'
end
