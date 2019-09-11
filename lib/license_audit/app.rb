# frozen_string_literal: true

module LicenseAudit
  class App
    attr_accessor :name, :repo, :env, :path, :build_command, :license_finder_opts, :location

    def initialize(name:, repo:, env:, path:, build_command:, license_finder_opts:)
      self.name = name
      self.repo = repo
      self.env = env
      self.path = path
      self.build_command = build_command
      self.license_finder_opts = license_finder_opts
      self.location = File.join(Config.project_root, path, name)
    end

    def self.load_apps(config, location = '.')
      config.apps.each_with_object({}) do |(name, app_data), hash|
        hash[name] = App.new(name: name, 
                             repo: app_data['repo'],
                             env: app_data['env'],
                             path: app_data['path'] || location,
                             build_command: app_data['build_command'],
                             license_finder_opts: app_data['license_finder_opts'])
      end
    end

    def repo_cloned?
      File.directory?(location)
    end

  end
end
