# frozen_string_literal: true

require 'open3'
require 'rainbow'

module LicenseAudit
  class Git
    class << self
      def current_branch(app)
        `cd #{app.location} && git rev-parse --abbrev-ref HEAD 2>&1`
      end

      def commits_behind(app, branch = nil)
        current_branch = current_branch(app).strip
        branch ||= current_branch
        count = `cd #{app.location} && git rev-list --right-only --count #{current_branch}...origin/#{branch} --`.strip
        count.to_i
      end

      def dirty_working_dir(app)
        `cd #{app.location} && git status --porcelain 2>/dev/null | egrep "^(M| M)" | wc -l`.strip != '0'
      end

      def clone_app(app)
        puts main_run("rm -rf #{app.location}") if File.exists?(app.location)
        puts main_run("git clone --recurse-submodules https://build@github.com/#{app.repo}.git #{app.location}")
      end

      def git_on_apps(*command, apps)
        Parallel.each(apps, in_processes: 4) do |_name, app|
          git(command, app.name, app.location)
        end
      end

      def git(*command, title, location)
        output = Rainbow("#{title}:\n").green
        command_output = main_run("cd #{location} && git #{command.join(' ')}")
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
