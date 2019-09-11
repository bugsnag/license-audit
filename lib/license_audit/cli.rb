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
      Dir.mkdir('build') unless Dir.exist?('build')
      Dir.mkdir('reports') unless Dir.exist?('reports')
    end

    def self.exit_on_failure?
      true
    end

    desc 'open_report', 'Opens the report file'
    def open_report()
        summary_file = File.open("reports/index.html", "w")
        summary_file.puts(File.read("summary_file_header.html"))
        summary_file.puts("<h1>Bugsnag Notifier Repository License Audit</h1>")
        summary_file.puts("<h3>Reports</h3><p>Run at: #{Time.new}")
        summary_file.puts("<table class='table'><thead><th>Repository</th><th>Build</th><th>Audit</th></thead><tbody>")
        summary_file.flush
        summary_file.close
    end

    desc 'close_report', 'Closes the report file'
    def close_report()
        summary_file = File.open("reports/index.html", "a")
        summary_file.puts("</tbody></table>")
        summary_file.puts("<p>Completed at: #{Time.new}</p>")
        summary_file.puts(File.read("summary_file_footer.html"))
        summary_file.close
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
      
      output_text = ''

      error_count = 0
      filtered_apps.each_with_index do |(name, app), index|
        
        puts
        puts Rainbow("[#{index + 1}/#{filtered_apps.length}] #{app.repo}").inverse

        output_text += "<tr><td><a href=\"https://github.com/#{app.repo}\">#{app.name}</a>"
        output_text += "[<a href=\"../apps/#{app.name}/doc/dependency_decisions.yml\">decision file</a>]</td>"

        unless !options[:clean] && app.repo_cloned?
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
          output_text += "<td><a href=\"../build/#{app.name}.txt\"><span class=\"badge badge-important\">&#x2717;</span></a></td><td></td></tr>"
          next
        else
          output_text += "<td><a href=\"../build/#{app.name}.txt\"><span class=\"badge badge-success\">&#x2713;</span></a></td>"
        end

        puts Rainbow("Running license check:").green
        if not LicenseFinder.run(app)
          puts Rainbow("[#{index + 1}/#{filtered_apps.length}] AUDIT FAILED: #{app.repo}").underline.red.inverse
          error_count += 1
          output_text += "<td><a href=\"../reports/#{app.name}.html\"><span class=\"badge badge-important\">&#x2717;</span></td></tr>"
        else
          puts Rainbow("[#{index + 1}/#{filtered_apps.length}] AUDIT PASSED: #{app.repo}").underline.green.inverse
          output_text += "<td><a href=\"../reports/#{app.name}.html\"><span class=\"badge badge-success\">&#x2713;</span></td></tr>"
        end

      end

    summary_file = File.open("reports/index.html", "a")
    summary_file.puts(output_text)
    summary_file.close
    
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
