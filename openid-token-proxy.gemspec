# encoding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'openid_token_proxy/version'

Gem::Specification.new do |spec|
  spec.name          = 'openid-token-proxy'
  spec.version       = OpenIDTokenProxy::VERSION
  spec.authors       = ['Tim Kurvers']
  spec.email         = ['johannes@hyper.no']
  spec.summary       = 'OpenID token proxy'
  spec.description   = 'OpenID token proxy'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'guard', '~> 2.12.5'
  spec.add_development_dependency 'guard-rspec', '~> 4.5.0'
  spec.add_development_dependency 'pry', '~> 0.10.1'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rails', '~> 4.2.1'
  spec.add_development_dependency 'rspec-rails', '~> 3.2.1'
end
