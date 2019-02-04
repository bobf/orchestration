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

          if ENV.key?('RABBITMQ_URL')
            @settings = from_url
            return
          end

          @settings = config.fetch(@env.environment)
          @settings.merge!('port' => PORT) unless @settings.key?('port')
        end

        def friendly_config
          "[bunny] amqp://#{host}:#{port}"
        end

        private

        def config
          yaml(File.read(@env.rabbitmq_configuration_path))
        end

        def host
          @settings.fetch('host')
        end

        def port
          @settings.fetch('port')
        end

        def from_url
          uri = URI.parse(ENV.fetch('RABBITMQ_URL'))
          { 'host' => uri.host, 'port' => uri.port || 5672 }
        end
      end
    end
  end
end
