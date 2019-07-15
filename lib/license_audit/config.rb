# frozen_string_literal: true

require 'yaml'

module LicenseAudit
  class Config
    CONFIG_FILENAME = 'license_audit.yml'

    def self.project_root
      @project_root ||= Pathname.getwd.ascend.find { |pth| (pth + CONFIG_FILENAME).file? }
    end

    def apps
      @apps ||= read(CONFIG_FILENAME)['apps']
    end

    private

    def read(filename)
      file_path = Config.project_root + filename
      unless file_path.file?
        puts "No configuration file found at #{file_path}"
        raise "No configuration file found at #{file_path}"
      end
      YAML.safe_load(File.read(file_path))
    end

  end
end
