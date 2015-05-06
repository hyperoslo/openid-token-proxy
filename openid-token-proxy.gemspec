# encoding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'openid_token_proxy/version'

Gem::Specification.new do |spec|
  spec.name          = 'openid-token-proxy'
  spec.version       = OpenIDTokenProxy::VERSION
  spec.authors       = ['Tim Kurvers']
  spec.email         = ['johannes@hyper.no']
  spec.summary       = 'Retrieves and refreshes OpenID tokens on behalf of a user'
  spec.description   = 'Retrieves and refreshes OpenID tokens on behalf of a user when dealing with complex authentication schemes, such as client-side certificates'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'openid_connect', '~> 0.8.3'
  spec.add_dependency 'rails', '~> 4.0'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'coveralls', '~> 0.7.12'
  spec.add_development_dependency 'guard', '~> 2.12.5'
  spec.add_development_dependency 'guard-rspec', '~> 4.5.0'
  spec.add_development_dependency 'pry', '~> 0.10.1'
  spec.add_development_dependency 'pry-rails', '~> 0.3.4'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec-rails', '~> 3.2.1'
  spec.add_development_dependency 'simplecov', '~> 0.9.2'
  spec.add_development_dependency 'webmock', '~> 1.21.0'
end
