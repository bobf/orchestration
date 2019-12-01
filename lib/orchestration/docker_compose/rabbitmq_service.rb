# frozen_string_literal: true

module Orchestration
  module DockerCompose
    class RabbitMQService
      def initialize(config, environment)
        @config = config
        @environment = environment
      end

      def definition
        return nil unless @config.enabled?

        { 'image' => 'library/rabbitmq' }.merge(ports)
      end

      def ports
        return {} unless %i[development test].include?(@environment)

        container_port = Orchestration::Services::RabbitMQ::PORT

        { 'ports' => ["#{Orchestration.random_local_port}:#{container_port}"] }
      end
    end
  end
end
