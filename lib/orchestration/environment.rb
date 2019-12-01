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

    def web_server
      # Used at installation time only
      ENV.fetch('server', 'puma')
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
      default = root.basename.to_s
      return default unless defined?(Rails)
      # Edge case if Rails is used as a dependency but we are not a Rails app:
      return default if Rails.application.class.parent == Object

      Rails.application.class.parent.name.underscore
    end

    def app_name
      settings.get('docker.repository')
    end

    def settings
      Settings.new(orchestration_configuration_path)
    end

    def root
      defined?(Rails) && Rails.root ? Rails.root : Pathname.new(Dir.pwd)
    rescue NoMethodError
      Pathname.new(Dir.pwd)
    end

    def orchestration_root
      root.join(orchestration_dir_name)
    end

    def orchestration_dir_name
      'orchestration'
    end

    def database_volume(env = nil)
      env ||= environment
      "#{app_name}_#{env}_database"
    end

    def mongo_volume(env = nil)
      env ||= environment
      "#{app_name}_#{env}_mongo"
    end
  end
end
