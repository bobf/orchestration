# frozen_string_literal: true

module Orchestration
  module Services
    module RabbitMQ
      class Configuration
        include ConfigurationBase

        self.service_name = 'rabbitmq'

        def enabled?
          defined?(::Bunny)
        end

        def friendly_config
          "[bunny] amqp://#{host}:#{port}"
        end

        def host
          from_url['host'] || super
        end

        def port
          from_url['port'] || super
        end

        private

        def from_url
          return {} if @env.rabbitmq_url.nil?

          uri = URI.parse(@env.rabbitmq_url)
          { 'host' => uri.host, 'port' => uri.port || 5672 }
        end
      end
    end
  end
end
