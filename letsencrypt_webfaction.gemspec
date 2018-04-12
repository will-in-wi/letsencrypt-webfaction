lib = File.expand_path('lib', __dir__)
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
  spec.require_paths = %w[lib]

  spec.cert_chain  = ['certs/will_in_wi.pem']
  spec.signing_key = File.expand_path('~/.ssh/gem-private_key.pem') if $PROGRAM_NAME.end_with?('gem')

  spec.required_ruby_version = '>= 2.1.0'

  spec.add_runtime_dependency 'acme-client', '~> 0.6.0'
  spec.add_runtime_dependency 'toml-rb', '~> 1.1'

  # This will be required for Ruby 2.4. But it is incompatible for Ruby <2.3. Unsupporting Ruby 2.4 for the moment.
  # spec.add_runtime_dependency 'xmlrpc', '~> 0.3.0'
end
