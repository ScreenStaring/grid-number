# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "grid_number"

Gem::Specification.new do |spec|
  spec.name          = "global_release_identifier"
  spec.version       = GRid::VERSION
  spec.authors       = ["Skye Shaw"]
  spec.email         = ["skye.shaw@gmail.com"]

  spec.summary       = %q{Class to represent Global Release Identifiers (GRid numbers).}
  spec.description   = <<-DESC
    Class to represent Global Release Identifiers (GRid numbers).
    GRid numbers are used to identify electronic music releases.
  DESC

  spec.homepage      = "https://github.com/ScreenStaring"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
