# frozen_string_literal: true

module HomeflowOrchestration
  module Services
    module RabbitMQ
      class Configuration
        attr_reader :settings

        def initialize(env)
          @env = env
          @settings = nil
          return unless defined?(RabbitMQ)
          return unless File.exist?(@env.rabbitmq_configuration_path)

          @settings = config.fetch(@env.environment)
          @settings.merge!('port' => PORT) unless @settings.key?('port')
        end

        def friendly_config
          host = @settings.fetch('host')
          port = @settings.fetch('port')

          "[bunny] amqp://#{host}:#{port}"
        end

        private

        def config
          YAML.safe_load(
            File.read(@env.rabbitmq_configuration_path), [], [], true
          )
        end
      end
    end
  end
end
