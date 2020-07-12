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
      case environment
      when 'development'
        ENV['DEVELOPMENT_DATABASE_URL'] || ENV['DATABASE_URL']
      when 'test'
        ENV['TEST_DATABASE_URL'] || ENV['DATABASE_URL']
      else
        ENV['DATABASE_URL']
      end
    end

    def mongo_url
      ENV['MONGO_URL']
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
      env ||= 'development'

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
      default = docker_filter(root.basename.to_s)
      return default unless defined?(Rails)
      # Edge case if Rails is used as a dependency but we are not a Rails app:
      return default if rails_application == Object

      docker_filter(rails_application.name.underscore)
    end

    def rabbitmq_url
      ENV.fetch('RABBITMQ_URL', nil)
    end

    def app_port
      ENV.fetch('PUBLISH_PORT', ENV.fetch('WEB_PORT', '3000')).to_i
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

    def database_volume
      'database'
    end

    def mongo_volume
      'mongo'
    end

    private

    def rails_application
      app_class = Rails.application.class
      # Avoid deprecation warning in Rails 6:
      # `Module#parent` has been renamed to `module_parent`. `parent`
      return app_class.module_parent if app_class.respond_to?(:module_parent)

      app_class.parent
    end

    def docker_filter(string)
      # Filter out characters not accepted by Docker Hub
      permitted = [('0'..'9'), ('a'..'z')].map(&:to_a).flatten
      string.split('').select { |char| permitted.include?(char) }.join
    end
  end
end
