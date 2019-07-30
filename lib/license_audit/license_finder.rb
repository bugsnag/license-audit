# frozen_string_literal: true

require 'open3'
require 'rainbow'
require 'license_audit/config'

module LicenseAudit
  class LicenseFinder
    class << self

      def build(app)
        puts app.build_command
        Bundler.with_clean_env do
            Dir.chdir app.location do
                return main_run(app.build_command)
            end
        end
      end

      def run(app)

        target_decision_file_dir = "#{app.location}/doc"
        source_decision_file_dir = "#{Config.project_root}/decision_files/"
        Dir.mkdir(target_decision_file_dir) unless File.exists?(target_decision_file_dir)
        File.open("#{target_decision_file_dir}/dependency_decisions.yml", 'w') do | decision_file |
          File.open("#{source_decision_file_dir}/global.yml") do | file |
            while line = file.gets
                decision_file.puts line
            end
          end
            File.open("#{source_decision_file_dir}/#{app.name}.yml") if File.exists?("#{source_decision_file_dir}/#{app.name}.yml") do | file |
            while line = file.gets
                decision_file.puts line
            end
          end
        end

        Bundler.with_clean_env do
            Dir.chdir app.location do
                return main_run("license_finder #{app.license_finder_opts}")
            end
        end

      end

      private

      def main_run(command)
        exit_code = nil
        Open3.popen2e(command) do |_stdin, stdout_stderr, _wait_thread|
          stdout_stderr.each { |l| puts l }
          exit_code = _wait_thread.value
        end
        return exit_code == 0
      end
    end
  end
end
