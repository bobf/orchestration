# frozen_string_literal: true

module Orchestration
  module Services
    module RabbitMQ
      class Configuration
        include ConfigurationBase

        self.service_name = 'rabbitmq'

        def initialize(env, service_name = nil)
          super
          @settings = nil
          return unless defined?(RabbitMQ)
          return unless File.exist?(@env.rabbitmq_configuration_path)

          @settings = config.fetch(@env.environment)
          @settings.merge!('port' => PORT) unless @settings.key?('port')
        end

        def friendly_config
          "[bunny] amqp://#{host}:#{local_port}"
        end

        private

        def config
          yaml(File.read(@env.rabbitmq_configuration_path))
        end
      end
    end
  end
end
