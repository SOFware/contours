# frozen_string_literal: true

require_relative "lib/contours/version"

Gem::Specification.new do |spec|
  spec.name = "contours"
  spec.version = Contours::VERSION
  spec.authors = ["Jim Gay"]
  spec.email = ["jim@saturnflyer.com"]

  spec.summary = "Support for building customizable configuration objects."
  spec.description = <<~DESC
    Provides objects with which you can define a configuration object
    which can be customized by merging in other configuration objects.
  DESC
  spec.homepage = "https://github.com/SOFware/contours"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/SOFware/contours.git"
  spec.files = Dir["lib/**/*", "LICENSE", "Rakefile", "README.md"]
  spec.require_paths = ["lib"]
end
