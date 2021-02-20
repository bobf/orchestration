# frozen_string_literal: true

module Orchestration
  module DockerCompose
    class RabbitMQService
      include ComposeHelpers

      def initialize(config, environment)
        @config = config
        @environment = environment
      end

      def definition
        return nil unless @config.enabled?

        { 'image' => 'library/rabbitmq:manager' }.merge(ports)
      end

      def ports
        return {} unless %i[development test].include?(@environment)

        container_port = Orchestration::Services::RabbitMQ::PORT
        manager_port = Orchestration::Services::RabbitMQ::MANAGER_PORT

        { 'ports' => ["#{sidecar_port(@environment)}#{container_port}",
                      "#{sidecar_port(@environment)}#{manager_port}"] }
      end
    end
  end
end
