# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'motosale_ua/version'

Gem::Specification.new do |spec|
  spec.name          = "motosale_ua"
  spec.version       = MotosaleUa::VERSION
  spec.authors       = ["kongo"]
  spec.email         = ["d.parshenko@gmail.com"]
  spec.description   = %q{Access motosale.ua from ruby code}
  spec.summary       = spec.description
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "<= 2.12"
  spec.add_runtime_dependency "nokogiri", "~> 1.6"
end
