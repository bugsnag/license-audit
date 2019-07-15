# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'license_audit/version'

Gem::Specification.new do |spec|
  spec.name          = "license_audit"
  spec.version       = LicenseAudit::VERSION
  spec.authors       = ["Tom Longridge"]
  spec.email         = ["tom@bugsnag.com"]

  spec.summary       = %q{Performs a license audit check on notifier repos}
  spec.homepage      = "https://bugsnag.com"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.bindir        = "bin"
  spec.executables   = ["license_audit"]
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '~> 2.4'

  spec.add_development_dependency "bundler", "~> 2.0.2"
  spec.add_development_dependency "rubocop", "~> 0.55.0"

  spec.add_runtime_dependency "thor", "~> 0.19"
  spec.add_runtime_dependency "colorize", "~> 0.8.1"
  spec.add_runtime_dependency "parallel", "~> 1.12.0"
  spec.add_runtime_dependency "license_finder", "~> 5.9.2"
  spec.add_runtime_dependency "rake", "~> 12.3.2"
  spec.add_runtime_dependency "backports", "~> 3.11.4"
  spec.add_runtime_dependency "builder", "~> 3.2.3"
  spec.add_runtime_dependency "cucumber-expressions", "5.0.15"
  spec.add_runtime_dependency "cucumber-wire", "0.0.1"
  spec.add_runtime_dependency "cucumber-tag_expressions", "~> 1.1.1"
  spec.add_runtime_dependency "gherkin", "~> 5.1.0"
  spec.add_runtime_dependency "cucumber", "~> 3.1.0"
  spec.add_runtime_dependency "cucumber-core", "~> 3.1.0"
  spec.add_runtime_dependency "diff-lcs", "~> 1.3"
  spec.add_runtime_dependency "multi_json", "~> 1.13.1"
  spec.add_runtime_dependency "multi_test", "~> 0.1.2"
  spec.add_runtime_dependency "minitest", "~> 5.11.3"
  spec.add_runtime_dependency "os", "1.0.0"
  spec.add_runtime_dependency "rack", "2.0.6"
  spec.add_runtime_dependency "power_assert", "1.1.3"
  spec.add_runtime_dependency "test-unit", "3.2.9"
  spec.add_runtime_dependency "coderay", "1.1.2"
  spec.add_runtime_dependency "method_source", "0.9.2"
  spec.add_runtime_dependency "pry", "0.12.2"

end
