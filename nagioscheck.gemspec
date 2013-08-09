# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nagioscheck/version'

Gem::Specification.new do |spec|
  spec.name          = "nagioscheck"
  spec.version       = NagiosCheck::VERSION
  spec.authors       = ["Aaron Brown"]
  spec.email         = ["aaron@9minutesnooze.com"]
  spec.description   = %q{Makes writing Nagios checks easier}
  spec.summary       = %q{Makes writing Nagios checks easier}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
