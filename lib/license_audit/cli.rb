# frozen_string_literal: true

require 'thor'
require 'parallel'
require 'rainbow'

require 'license_audit/git'
require 'license_audit/license_finder'
require 'license_audit/config'
require 'license_audit/app'
require 'license_audit/report'

module LicenseAudit
  class CLI < Thor
    attr_accessor :config, :apps

    def initialize(*args)
      super
      self.config = Config.new
      self.apps = App.load_apps(config, 'apps')
      Dir.mkdir('build') unless Dir.exist?('build')
      Dir.mkdir('reports') unless Dir.exist?('reports')
    end

    def self.exit_on_failure?
      true
    end

    desc 'audit', 'Run the license audit'
    option :clean, :desc => 'Whether to re-clone repository'
    option :app, :desc => 'The name of the repository to check'
    option :env, :desc => 'The build environment present'
    def audit()

      puts Rainbow("Running audit with app: #{options[:app]}").green if options.key?(:app)
      puts Rainbow("Running audit with environment: #{options[:env]}").green if options.key?(:env)

      filtered_apps = apps.select{ |key, app| (!options.key?(:app) || key == options[:app]) && (!options.key?(:env) || app.env == options[:env]) }

      if filtered_apps.length == 0
        puts
        puts Rainbow("No apps found that match specified arguments").underline.red.inverse
        puts
        exit 1
      end

      Report.create()

      error_count = 0
      filtered_apps.each_with_index do |(name, app), index|
        
        puts
        puts Rainbow("[#{index + 1}/#{filtered_apps.length}] #{app.repo}").inverse

        if options[:clean] || !app.repo_cloned?
          puts Rainbow("Cloning #{app.repo}").green
          Git.clone_app(app)
        end

        Git.git('checkout -- .', 'Reverting local changes', app.location)
        Git.git('fetch', 'Get latest', app.location)
        Git.git("checkout #{app.branch}", "Checkout #{app.branch} branch", app.location)
        Git.git('pull', 'Refresh branch', app.location)

        puts Rainbow("Building repo:").green
        build_suceeded = LicenseFinder.build(app)
        audit_succeeded = false
        
        if not build_suceeded
          puts Rainbow("[#{index + 1}/#{filtered_apps.length}] BUILD FAILED: #{app.repo}").underline.red.inverse
          error_count += 1
        else
          puts Rainbow("Running license check:").green

          audit_succeeded = LicenseFinder.run(app)
          if not audit_succeeded
            puts Rainbow("[#{index + 1}/#{filtered_apps.length}] AUDIT FAILED: #{app.repo}").underline.red.inverse
            error_count += 1
          else
            puts Rainbow("[#{index + 1}/#{filtered_apps.length}] AUDIT PASSED: #{app.repo}").underline.green.inverse
          end
          
        end
        
        Report.addAppRun(app, build_suceeded, audit_succeeded)
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