# frozen_string_literal: true

module Orchestration
  module DockerCompose
    class RabbitMQService
      def initialize(config, environment)
        @config = config
        @environment = environment
      end

      def definition
        return nil if @config.settings.nil?

        { 'image' => 'library/rabbitmq' }.merge(ports)
      end

      def ports
        return {} unless %i[development test].include?(@environment)

        host_port = @config.settings.fetch('port', 5672)
        container_port = Orchestration::Services::RabbitMQ::PORT

        { 'ports' => ["#{host_port}:#{container_port}"] }
      end
    end
  end
end
