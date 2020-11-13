# frozen_string_literal: true

module LicenseAudit
  class App
    attr_accessor :name, :repo, :env, :location, :working_dir, :default_branch, :build_command, :license_finder_opts

    def initialize(name:, repo:, env:, location:, working_dir:, default_branch:, build_command:, license_finder_opts:)
      self.name = name
      self.repo = repo
      self.env = env
      self.location = location
      self.working_dir = working_dir
      self.default_branch = default_branch
      self.build_command = build_command
      self.license_finder_opts = license_finder_opts
    end

    def self.load_apps(config, location = '.')
      config.apps.each_with_object({}) do |(name, app_data), hash|
        hash[name] = App.new(name: name, 
                             repo: app_data['repo'],
                             env: app_data['env'],
                             location: File.join(Config.project_root, location, name),
                             working_dir: app_data['working_dir'] || ['.'],
                             default_branch: app_data['default_branch'] || 'master',
                             build_command: app_data['build_command'],
                             license_finder_opts: app_data['license_finder_opts'])
      end
    end

    def report_name(branch, working_dir)
      name = self.name.dup
      branch_name = branch.dup
      branch_name.gsub! '/', '_'
      name += "_" + branch_name
      if !working_dir.eql? '.'
        working_dir_name = working_dir.dup
        working_dir_name.gsub! '/', '_'
        name += "_" + working_dir_name
      end
      name
    end

    def report_readable_name(branch, working_dir)
      name = self.name.dup
      if !working_dir.eql? '.'
        name += " (#{working_dir})"
      end
      name += " on " + branch
      name
    end

    def repo_cloned?
      File.directory?(location)
    end

  end
end
