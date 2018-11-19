# frozen_string_literal: true

module HomeflowOrchestration
  module DockerCompose
    class RabbitMQService
      def initialize(config)
        @config = config
      end

      def definition
        return nil if @config.settings.nil?

        host_port = @config.settings.fetch('port', 5672)
        container_port = HomeflowOrchestration::Services::RabbitMQ::PORT

        {
          'image' => 'library/rabbitmq',
          'ports' => ["#{host_port}:#{container_port}"]
        }
      end
    end
  end
end
