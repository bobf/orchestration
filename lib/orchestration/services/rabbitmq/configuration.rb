# frozen_string_literal: true

module Orchestration
  module Services
    module RabbitMQ
      class Configuration
        include ConfigurationBase

        self.service_name = 'rabbitmq'

        def enabled?
          defined?(RabbitMQ)
        end

        def friendly_config
          "[bunny] amqp://#{host}:#{port}"
        end

        def host
          return from_url['host'] unless @env.rabbitmq_url.nil?

          super
        end

        def port
          return from_url['port'] unless @env.rabbitmq_url.nil?

          super
        end

        private

        def from_url
          uri = URI.parse(@env.rabbitmq_url)
          { 'host' => uri.host, 'port' => uri.port || 5672 }
        end
      end
    end
  end
end
