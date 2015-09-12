# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cloudcheckr/version'

Gem::Specification.new do |spec|
  spec.name          = "cloudcheckr"
  spec.version       = Cloudcheckr::VERSION
  spec.authors       = ["Joel Van Horn"]
  spec.email         = ["joel@joelvanhorn.com"]
  spec.summary       = %q{CloudCheckr API client}
  spec.description   = %q{Ruby client for CloudCheckr API.}
  spec.homepage      = "https://github.com/betastream/cloudcheckr"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday"
  spec.add_dependency "faraday_middleware"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "faraday-detailed_logger"
end
