# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bedsonline/version'

Gem::Specification.new do |spec|
  spec.name          = "bedsonline"
  spec.version       = Bedsonline::VERSION
  spec.authors       = ["Ricardo Echavarria", "Andrei Helo"]
  spec.email         = ["rgechavarria@gmail.com", "andreihelo@gmail.com"]
  spec.summary       = %q{Connect to Bedsonline XML hotel services}
  spec.description   = %q{Connect to Bedsonline XML hotel services}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "activesupport"
  spec.add_dependency "httparty", "~>0.13.1"
  spec.add_dependency "nokogiri"
  spec.add_dependency "activerecord"
  spec.add_dependency "mysql"
end
