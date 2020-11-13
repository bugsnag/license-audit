# frozen_string_literal: true

require 'open3'
require 'date'
require 'time'

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
        puts main_run("git clone --recurse-submodules git://github.com/#{app.repo}.git #{app.location}")
      end

      def git_on_apps(*command, apps)
        Parallel.each(apps, in_processes: 4) do |_name, app|
          git(command, app.name, app.location)
        end
      end

      def git(*command, location)
        command_output = main_run("cd #{location} && git #{command.join(' ')}")
        output_without_blank_lines = command_output.each_line.reject { |l| l.strip.empty? }
        output = ""
        output_without_blank_lines.each { |line| output += "   #{line}" }
        output
      end

      def get_recently_modified_branches(location, num_days)
        command_output = main_run("cd #{location} && git for-each-ref --sort=-committerdate --format='%(committerdate:short) %(refname)' refs/remotes")
        branches = Set.new
        output_without_blank_lines = command_output.each_line.reject { |l| l.strip.empty? }
        output_without_blank_lines.each { |line| 
          fields = line.split(' ')
          if Date.parse(fields[0]) >= Date.today - num_days
            branch_name = fields[1].sub("refs/remotes/origin/", "")
            branches.add(branch_name) unless branch_name == "HEAD"
          end
        }
        return branches
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
