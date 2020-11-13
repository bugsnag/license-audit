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
            # Run the report first...
            main_run("license_finder report --format html #{app.license_finder_opts} > #{Config.project_root}/reports/#{app.report_name(branch, working_dir)}.html 2>&1")
            # Then re-run for the return code and stderr output to console
            output = []
            success = main_run("license_finder #{app.license_finder_opts}", output)
            # There should always be dependencies - return false if they weren't found to prevent us missing this
            return success && !output.last().strip().eql?("No dependencies recognized!")
          end
        end

      end

      private

      def main_run(command, output=[])
        exit_code = nil
        Open3.popen2e(command) do |_stdin, stdout_stderr, _wait_thread|
          stdout_stderr.each { |l| 
            begin
              puts l
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
