# encoding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'openid-token-proxy/version'

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
  spec.add_development_dependency 'rake', '~> 10.0'
end
