# frozen_string_literal: true

require 'thor'
require 'parallel'
require 'rainbow'
require 'pathname'

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
    option :app, :desc => 'The name of the repository to check'
    option :build, :desc => 'Re-run the audit with no build'
    option :clean, :desc => 'Whether to re-clone repository'
    option :dir, :desc => 'The directory to audit'
    option :env, :desc => 'The build environment present'
    option :recent, :desc => 'Scan all branches modified in the specified number of days'
    option :wait, :desc => 'Used for docker-based troubleshooting: set it to "before" or "after" to wait indefinitely before or after the audit'
    def audit()

      filtered_apps = apps
      if options.key?(:app) && !options[:app].empty?
        puts Rainbow("Running audit with app: #{options[:app]}").blue if options.key?(:app)
        filtered_apps = filtered_apps.select{ |key, app| key == options[:app] }
      end

      if options.key?(:env) && !options[:env].empty?
        puts Rainbow("Running audit with environment: #{options[:env]}").blue if options.key?(:env)
        filtered_apps = filtered_apps.select{ |key, app| app.env == options[:env] }
      end

      puts Rainbow("License Finder version: #{LicenseFinder.version()}").blue

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

        if !app.repo_cloned?
          puts Rainbow("Cloning #{app.repo}").blue
          Git.clone_app(app)
        end

        puts
        puts Rainbow("Auditing branch: #{app.default_branch}").blue
        recent_branches = Set.new
        recent_branches.add(app.default_branch)
        if options.key?(:recent) && !options[:recent].empty?
          recent_branches |= Git.get_recently_modified_branches(app.location, options[:recent].to_i)
          puts Rainbow("             ... and #{recent_branches.size() - 1} branches updated in the last #{options[:recent]} days").blue
        end

        working_dir_count = 0
        working_dir_errors = 0

        recent_branches.each { |branch|

          if !options.key?(:clean) || options[:clean].to_s.downcase == "true"
            puts
            puts Rainbow("Reverting local changes").blue
            Git.git('checkout -- .', app.location)
            puts Rainbow("Get latest").blue
            Git.git('fetch', app.location)
            puts Rainbow("Checkout #{branch} branch").blue
            puts Git.git("checkout #{branch}", app.location)
            puts Rainbow("Reset to origin").blue
            puts Git.git("reset --hard origin/#{branch}", app.location)
            puts Rainbow("Refresh branch").blue
            puts Git.git('pull', app.location)
          end

          if options.key?(:wait) && options[:wait].to_s.downcase == "before"
            puts Rainbow("Waiting before audit due to 'wait' option").blue
            STDIN.gets.chomp
          end

          if options.key?(:dir) && !options[:dir].empty?
            working_dir_patterns = [options[:dir]]
          else
            working_dir_patterns = app.working_dir
          end

          working_dir_patterns.each { |working_dir_pattern|

            Dir.glob(File.join(app.location, working_dir_pattern)).select{ |file| File.directory?(file) }.each { |working_dir_abs|
              
              working_dir = Pathname.new(working_dir_abs).relative_path_from(Pathname.new(app.location)).to_s
              working_dir_count += 1

              if !options.key?(:build) || options[:build].empty? || options[:build].to_s.downcase == "true"
                puts
                puts Rainbow("Building #{app.report_readable_name(branch, working_dir)}").blue
                build_suceeded = LicenseFinder.build(app, branch, working_dir)
              else
                puts Rainbow("Skipping build #{app.report_readable_name(branch, working_dir)}").blue
                build_suceeded = true
              end
              audit_succeeded = false
              
              puts
              if not build_suceeded
                puts Rainbow("BUILD FAILED: #{app.report_readable_name(branch, working_dir)}").underline.red.inverse
                working_dir_errors += 1
              else
                puts Rainbow("Running license check:").blue

                audit_succeeded = LicenseFinder.run(app, branch, working_dir)
                if not audit_succeeded
                  puts Rainbow("CHECK FAILED: #{app.report_readable_name(branch, working_dir)}").underline.red.inverse
                  working_dir_errors += 1
                else
                  puts Rainbow("CHECK PASSED: #{app.report_readable_name(branch, working_dir)}").underline.green.inverse
                end
                
              end
              
              Report.addAppRun(app, branch, working_dir, build_suceeded, audit_succeeded)

            }
          }
        }

        if working_dir_errors > 0
          error_count += 1
          puts
          puts Rainbow("[#{index + 1}/#{filtered_apps.length}] REPO FAILED: #{app.name} (failed #{working_dir_errors} of #{working_dir_count} builds)").underline.red.inverse
        else
          puts
          puts Rainbow("[#{index + 1}/#{filtered_apps.length}] REPO PASSED: #{app.name} (#{working_dir_count} builds)").underline.green.inverse
        end

      end

      if error_count == 0
        puts
        puts Rainbow("AUDIT COMPLETED SUCCESSFULLY (#{filtered_apps.length} repos)").underline.blue.inverse
        puts
        exit 0
      else
        puts
        puts Rainbow("AUDIT FAILED (failed #{error_count} of #{filtered_apps.length} repos)").underline.red.inverse
        puts
        exit 1
      end

      if options.key?(:wait) && options[:wait].to_s.downcase == "after"
        puts Rainbow("Waiting after audit due to 'wait' option")
        STDIN.gets.chomp
      end

    end

    default_task :audit

    desc 'version', 'Display the CLI version'
    def version
      puts LicenseAudit::VERSION
    end

  end

end