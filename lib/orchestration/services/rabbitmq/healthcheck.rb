# frozen_string_literal: true

module Orchestration
  module Services
    module RabbitMQ
      class Healthcheck
        include HealthcheckBase

        dependencies 'bunny'

        def connection_errors
          [
            Bunny::TCPConnectionFailedForAllHosts,
            AMQ::Protocol::EmptyResponseError,
            Errno::ECONNRESET
          ]
        end

        def connect
          host = @configuration.host
          port = @configuration.port
          connection = Bunny.new("amqp://#{host}:#{port}", log_file: devnull)
          connection.start
          connection.stop
        end
      end
    end
  end
end
