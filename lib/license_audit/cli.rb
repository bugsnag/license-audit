# frozen_string_literal: true

require 'thor'
require 'parallel'
require 'rainbow'

require 'license_audit/git'
require 'license_audit/license_finder'
require 'license_audit/config'
require 'license_audit/app'

module LicenseAudit
  class CLI < Thor
    attr_accessor :config, :apps

    def initialize(*args)
      super
      self.config = Config.new
      self.apps = App.load_apps(config, 'apps')
    end

    def self.exit_on_failure?
      true
    end

    desc 'audit', 'Run the license audit'
    option :clean
    def audit(app_name=nil)

      filtered_apps = apps.select{ |key, value| app_name == nil or key == app_name }

      error_count = 0
      filtered_apps.each_with_index do |(name, app), index|
        
        puts
        puts Rainbow("[#{index + 1}/#{filtered_apps.length}] #{app.repo}").inverse

        unless app.repo_cloned?
          puts Rainbow("Cloning #{app.repo}").green
          Git.clone_app(app)
        end

        Git.git('checkout master', 'Checkout master', app.location)
        Git.git('pull', 'Get latest master', app.location)
        Git.git('checkout -- .', 'Reverting local changes', app.location) if options[:clean]

        puts Rainbow("Building repo:").green
        if not LicenseFinder.build(app)
          puts Rainbow("[#{index + 1}/#{filtered_apps.length}] BUILD FAILED: #{app.repo}").underline.red.inverse
          error_count += 1
          next
        end

        puts Rainbow("Running license check:").green
        if not LicenseFinder.run(app)
          puts Rainbow("[#{index + 1}/#{filtered_apps.length}] AUDIT FAILED: #{app.repo}").underline.red.inverse
          error_count += 1
        else
          puts Rainbow("[#{index + 1}/#{filtered_apps.length}] AUDIT PASSED: #{app.repo}").underline.green.inverse
        end

      end

      if error_count == 0
        puts
        puts Rainbow("AUDIT COMPLETED SUCCESSFULLY (#{filtered_apps.length} repos)").underline.green.inverse
        puts
        exit 0
      else
        puts
        puts Rainbow("AUDIT FAILED (failed #{error_count} of #{filtered_apps.length})").underline.red.inverse
        puts
        exit 1
      end

    end

    default_task :audit

    desc 'version', 'Display the CLI version'
    def version
      puts LicenseAudit::VERSION
    end

  end
end
