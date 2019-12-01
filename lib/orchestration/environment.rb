# frozen_string_literal: true

module Orchestration
  class Environment
    def initialize(options = {})
      @environment = options.fetch(:environment, nil)
    end

    def environment
      return @environment unless @environment.nil?

      ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
    end

    def database_url
      ENV['DATABASE_URL']
    end

    def mongoid_configuration_path
      root.join('config', 'mongoid.yml')
    end

    def database_configuration_path
      root.join('config', 'database.yml')
    end

    def rabbitmq_configuration_path
      root.join('config', 'rabbitmq.yml')
    end

    def orchestration_configuration_path
      root.join('.orchestration.yml')
    end

    def docker_compose_configuration_path
      orchestration_root.join('docker-compose.yml')
    end

    def docker_compose_config
      YAML.safe_load(File.read(docker_compose_configuration_path))
    end

    def docker_compose_config?
      docker_compose_configuration_path.file?
    end

    def default_application_name
      Rails.application.class.parent.name.underscore
    end

    def application_name
      settings.get('docker.repository')
    end

    def settings
      Settings.new(orchestration_configuration_path)
    end

    def root
      return Rails.root if defined?(Rails) && Rails.root

      Pathname.new(Dir.pwd)
    end

    def orchestration_root
      root.join(orchestration_dir_name)
    end

    def orchestration_dir_name
      'orchestration'
    end

    def public_volume
      "#{application_name}_public"
    end
  end
end
