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

        { 'image' => 'library/rabbitmq:management' }.merge(ports)
      end

      def ports
        return {} unless %i[development test].include?(@environment)

        container_port = Orchestration::Services::RabbitMQ::PORT
        management_port = Orchestration::Services::RabbitMQ::MANAGEMENT_PORT

        { 'ports' => ["#{sidecar_port(@environment)}#{container_port}",
                      "#{sidecar_port(@environment)}#{management_port}"] }
      end
    end
  end
end
