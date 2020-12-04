# frozen_string_literal: true

require 'open3'
require 'license_audit/config'

module LicenseAudit
  class LicenseFinder
    class << self

      def build(app, branch, working_dir)
        return_code = 0
        app.build_command.each { |command|
            Bundler.with_original_env do
                Dir.chdir File.join(app.location, working_dir) do
                    puts "  " + command
                    return false unless main_run("#{command} >> #{Config.project_root}/build/#{app.report_name(branch, working_dir)}.txt 2>&1")
                end
            end
        } unless app.build_command.nil?
        return true
      end

      def run(app, branch, working_dir)

        target_decision_file_dir = "#{File.join(app.location, working_dir)}/doc"
        source_decision_file_dir = "#{Config.project_root}/config/decision_files/"
        Dir.mkdir(target_decision_file_dir) unless File.exists?(target_decision_file_dir)
        File.open("#{target_decision_file_dir}/dependency_decisions.yml", 'w') do | decision_file |
          File.open("#{source_decision_file_dir}/global.yml") do | file |
            while line = file.gets
                decision_file.puts line
            end
          end

          # decision_file.puts "#{source_decision_file_dir}#{app.name}.yml"
          if File.exists?("#{source_decision_file_dir}#{app.name}.yml")
            File.open("#{source_decision_file_dir}#{app.name}.yml") do | file |
              while line = file.gets
                  decision_file.puts line
              end
            end
          end
        end

        Bundler.with_original_env do
          Dir.chdir File.join(app.location, working_dir) do
            main_run("license_finder project_name add \"#{app.report_readable_name(branch, working_dir)}\"")
            
            report_file = "#{Config.project_root}/reports/#{app.report_name(branch, working_dir)}.html"

            main_run("license_finder report --format html #{app.license_finder_opts} --save #{report_file}")
            
            # The exit code only refers to the generation of the report, not the success of the audit
            # Read the report to make sure there are no failure badges and >1 dependencies scanned.
            failure_conditions = File.open report_file do |file|
              file.find { |line| line =~ /(badge badge\-important|<h4>0 total<\/h4>)/ }
            end

            return failure_conditions.nil?
          end
        end

      end

      def version()
        Bundler.with_original_env do
          output = []
          main_run("license_finder version", output)
          output[0]
        end
      end

      private

      def main_run(command, output=[], console_output=false)
        exit_code = nil
        Open3.popen2e(command) do |_stdin, stdout_stderr, _wait_thread|
          stdout_stderr.each { |l| 
            begin
              puts l if console_output
              output.push(l)
            end
          }
          exit_code = _wait_thread.value
        end
        return exit_code == 0
      end
    end
  end
end
