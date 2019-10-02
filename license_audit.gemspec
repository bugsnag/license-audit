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
  spec.required_ruby_version = '>= 2.3'

  spec.add_development_dependency "bundler", ">= 1.13"
  spec.add_development_dependency "rubocop", "~> 0.55.0"

  spec.add_runtime_dependency "thor", "~> 0.19"
  spec.add_runtime_dependency "rainbow", "~> 3.0.0"
  spec.add_runtime_dependency "rubyzip", ">= 1.3"

end
