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

        private

        def host
          return from_url['host'] if ENV.key?('RABBITMQ_URL')

          '127.0.0.1'
        end

        def port
          return from_url['port'] if ENV.key?('RABBITMQ_URL')

          DockerCompose::ComposeConfiguration.new(@env).local_port('rabbitmq')
        end

        def from_url
          uri = URI.parse(ENV.fetch('RABBITMQ_URL'))
          { 'host' => uri.host, 'port' => uri.port || 5672 }
        end
      end
    end
  end
end
