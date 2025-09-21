# frozen_string_literal: true

require_relative "lib/google/genai/version"

Gem::Specification.new do |spec|
  spec.name          = "google-genai"
  spec.version       = Google::Genai::VERSION
  spec.authors       = ["Google LLC"]
  spec.email         = ["googleapis-packages@google.com"]

  spec.summary       = "Ruby SDK for Google's Gemini API."
  spec.description   = "This gem provides a Ruby interface for developers to integrate Google's generative models, including the Gemini family, into their applications."
  spec.homepage      = "https://github.com/google/ruby-genai"
  spec.license       = "Apache-2.0"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/google/ruby-genai"
  spec.metadata["changelog_uri"] = "https://github.com/google/ruby-genai/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem.
  spec.files = Dir.glob("{lib}/**/*") + %w(README.md LICENSE CHANGELOG.md)

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_dependency "faraday", "~> 2.13"
  spec.add_dependency "faraday-retry", "~> 2.3"
  spec.add_dependency "googleauth", "~> 1.8"
  spec.add_dependency "mimemagic", "~> 0.4"
  spec.add_dependency "zeitwerk", "~> 2.6"
  spec.add_dependency "websocket-client-simple", "~> 0.3.0"

  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.30"
end
