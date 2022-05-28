# frozen_string_literal: true

module Orchestration
  module DockerCompose
    class InstallGenerator
      include FileHelpers

      def initialize(env, terminal)
        @env = env
        @terminal = terminal
      end

      def docker_compose_test_yml
        create_compose_file(:test)
      end

      def docker_compose_development_yml
        create_compose_file(:development)
      end

      def docker_compose_deployment_yml
        create_compose_file(:deployment)
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
          'services' => services(environment),
          'volumes' => volumes(environment),
          'networks' => compose_config(environment).networks
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
          configurations(environment).to_h
        )
      end

      def service_names(environment)
        case environment
        when :test, :development
          %i[database mongo rabbitmq redis]
        when :deployment
          %i[app database mongo rabbitmq redis]
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
          redis: Orchestration::Services::Redis::Configuration
        }.fetch(service).new(@env)
      end

      def service_enabled?(service_name)
        return false unless configuration(service_name).enabled?

        true
      end
    end
  end
end
