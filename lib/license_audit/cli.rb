# frozen_string_literal: true

require 'thor'
require 'parallel'
require 'rainbow'

require 'license_audit/git'
require 'license_audit/build_repo'
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

    desc 'run_audit', 'Run the license audit'
    def run_audit

      puts 'Running license audit...'

      apps.each_with_index do |(name, app), index|
        
        puts Rainbow("Running #{app.location} (#{index + 1}/#{apps.length})").underline

        unless app.repo_cloned?
          puts Rainbow("Cloning #{app.repo}").green
          Git.clone_app(app)
        end

        Git.git('checkout master', 'Checkout master', app.location)
        Git.git('pull', 'Get latest master', app.location)

        BuildRepo.build_repo(app.build_command, 'Building Repo', app.location)
        LicenseFinder.license_finder("--decisions-file=#{Config.project_root}/decision_files/#{app.name}.yml", 'Running License Finder', app.location)

      end

    end

    desc 'version', 'Display the CLI version'
    def version
      puts LicenseAudit::VERSION
    end

    private 

    def clone_apps
      
    end

  end
end
