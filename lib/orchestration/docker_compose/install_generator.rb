# frozen_string_literal: true

module Orchestration
  module DockerCompose
    class InstallGenerator
      include FileHelpers

      def initialize(env, terminal)
        @env = env
        @terminal = terminal
      end

      def docker_compose_yml
        create_compose_file
      end

      def docker_compose_test_yml
        create_compose_file(:test)
      end

      def docker_compose_development_yml
        create_compose_file(:development)
      end

      def docker_compose_local_yml
        create_compose_file(:local)
      end

      def docker_compose_production_yml
        create_compose_file(:production)
      end

      def docker_compose_override_yml
        simple_copy(
          'docker-compose.override.yml',
          @env.docker_compose_path(:override),
          overwrite: false
        )
      end

      def enabled_services(environment)
        service_names(environment).select { |name| service_enabled?(name) }
      end

      private

      def create_compose_file(environment = nil)
        path = @env.docker_compose_path(environment)
        create_file(
          path,
          structure(environment).to_yaml,
          overwrite: false
        )
      end

      def structure(environment = nil)
        {
          'version' => compose_config(environment).version,
          'services' => services(environment)
        }
      end

      def services(environment)
        compose_config(environment).services
      end

      def volumes(environment)
        return {} if environment.nil? || environment == :test

        compose_config(environment).volumes
      end

      def compose_config(environment)
        DockerCompose::Configuration.new(
          @env,
          environment,
          Hash[configurations(environment)]
        )
      end

      def service_names(environment)
        case environment
        when :test, :development
          %i[database mongo rabbitmq]
        when :production
          %i[haproxy app database mongo rabbitmq]
        when :local, nil
          []
        else
          raise ArgumentError, environment.inspect
        end
      end

      def configurations(environment)
        service_names(environment).map do |key|
          [key, configuration(key)]
        end
      end

      def configuration(service)
        {
          app: Orchestration::Services::App::Configuration,
          database: Orchestration::Services::Database::Configuration,
          mongo: Orchestration::Services::Mongo::Configuration,
          rabbitmq: Orchestration::Services::RabbitMQ::Configuration,
          haproxy: Orchestration::Services::HAProxy::Configuration
        }.fetch(service).new(@env)
      end

      def service_enabled?(service_name)
        return false if configuration(service_name).settings.nil?

        true
      end
    end
  end
end
