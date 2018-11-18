# frozen_string_literal: true

module Orchestration
  module Services
    module RabbitMQ
      class Healthcheck
        include HealthcheckBase

        def initialize(env)
          @configuration = Configuration.new(env)
        end

        def connection_errors
          [Bunny::TCPConnectionFailedForAllHosts]
        end

        def connect
          host = @configuration.settings.fetch('host')
          port = @configuration.settings.fetch('port')

          connection = Bunny.new("amqp://#{host}:#{port}")
          connection.start
          connection.stop
        end
      end
    end
  end
end
