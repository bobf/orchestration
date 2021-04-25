# frozen_string_literal: true

module Orchestration
  # rubocop:disable Metrics/ClassLength
  class Environment
    def initialize(options = {})
      @environment = options.fetch(:environment, nil)
    end

    def environment
      return @environment unless @environment.nil?

      ENV.fetch('RAILS_ENV') { ENV.fetch('RACK_ENV', 'development') }
    end

    def web_server
      # Used at installation time only
      ENV.fetch('server', 'puma')
    end

    def database_url
      case environment
      when 'development'
        ENV.fetch('DEVELOPMENT_DATABASE_URL') { ENV.fetch('DATABASE_URL', nil) }
      when 'test'
        ENV.fetch('TEST_DATABASE_URL') { ENV.fetch('DATABASE_URL', nil) }
      else
        ENV.fetch('DATABASE_URL', nil)
      end
    end

    def mongo_url
      ENV.fetch('MONGO_URL', nil)
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

    def kubernetes_configuration_path
      orchestration_root.join('kubernetes')
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
      default = docker_filter(root.basename.to_s, underscore: true)
      return default unless defined?(Rails)
      # Edge case if Rails is used as a dependency but we are not a Rails app:
      return default if rails_application == Object

      docker_filter(rails_application.name.underscore, underscore: true)
    end

    def rabbitmq_url
      ENV.fetch('RABBITMQ_URL', nil)
    end

    def app_port
      ENV.fetch('PUBLISH_PORT', ENV.fetch('WEB_PORT', '3000')).to_i
    end

    def organization
      settings.get('docker.organization')
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

    def docker_filter(string, underscore: false)
      # Filter out characters not accepted by Docker Hub
      permitted = [('0'..'9'), ('a'..'z')].map(&:to_a).flatten
      string.chars.select do |char|
        next true if underscore && char == '_'

        permitted.include?(char)
      end.join
    end
  end
  # rubocop:enable Metrics/ClassLength
end
