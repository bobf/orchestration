# frozen_string_literal: true

module Orchestration
  class KubernetesInstallGenerator
    include FileHelpers

    def initialize(env, terminal)
      @env = env
      @terminal = terminal
    end

    def kubernetes_deployment_yml
      create_compose_file(:deploy)
    end

    private

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
        %i[database mongo rabbitmq]
      when :deployment
        %i[app database mongo rabbitmq]
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
        rabbitmq: Orchestration::Services::RabbitMQ::Configuration
      }.fetch(service).new(@env)
    end

    def service_enabled?(service_name)
      return false unless configuration(service_name).enabled?

      true
    end
  end
end
