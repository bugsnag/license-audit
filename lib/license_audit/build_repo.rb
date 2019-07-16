# frozen_string_literal: true

require 'open3'

module LicenseAudit
  class BuildRepo
    class << self

      def build_repo(*command, title, location)
        output = "\u001b[32m#{title}\u001b[0m:\n"
        command_output = main_run("cd #{location} && #{command.join(' ')}")
        output_without_blank_lines = command_output.each_line.reject { |l| l.strip.empty? }
        output_without_blank_lines.each { |line| output += "   #{line}" }
        puts output
      end

      private

      def main_run(command)
        output = ''
        Open3.popen2e(command) do |_stdin, stdout_stderr, _wait_thread|
          stdout_stderr.each { |l| output += l }
        end
        output
      end
    end
  end
end
