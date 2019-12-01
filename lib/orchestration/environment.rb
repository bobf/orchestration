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

    def docker_api_version
      '3.7'
    end

    def docker_compose_path(env = nil)
      return orchestration_root.join('docker-compose.yml') if env.nil?

      orchestration_root.join("docker-compose.#{env}.yml")
    end

    def docker_compose_config(env = nil)
      env ||= environment
      YAML.safe_load(File.read(docker_compose_path(env)))
    end

    def docker_compose_config?(env = nil)
      env ||= environment
      docker_compose_path(env).file?
    end

    def default_app_name
      Rails.application.class.parent.name.underscore
    end

    def app_name
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
      "#{app_name}_public"
    end

    def database_volume
      "#{app_name}_database"
    end

    def mongo_volume
      "#{app_name}_mongo"
    end
  end
end
