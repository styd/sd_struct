# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sd_struct/version'

Gem::Specification.new do |spec|
  spec.name          = "sd_struct"
  spec.version       = SDStruct::VERSION
  spec.authors       = ["Adrian Setyadi"]
  spec.email         = ["a.styd@yahoo.com"]
  spec.summary       = %q{Strict and Deep Struct}
  spec.description   = %q{An alternative to OpenStruct that more strict in assigning values and deeper in
consuming the passed Hash and transforming it back to Hash or JSON, equipped
with deep digging capabilities.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport", ">= 4.0"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
