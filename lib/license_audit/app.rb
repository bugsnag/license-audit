# frozen_string_literal: true

module LicenseAudit
  class App
    attr_accessor :name, :repo, :path, :build_command, :location

    def initialize(name:, repo:, path:, build_command:)
      self.name = name
      self.repo = repo
      self.path = path
      self.build_command = build_command
      self.location = File.join(Config.project_root, path, name)
    end

    def self.load_apps(config, location = '.')
      config.apps.each_with_object({}) do |(name, app_data), hash|
        hash[name] = App.new(name: name, 
                             repo: app_data['repo'],
                             path: app_data['path'] || location,
                             build_command: app_data['build-command'])
      end
    end

    def repo_cloned?
      File.directory?(location)
    end

  end
end
