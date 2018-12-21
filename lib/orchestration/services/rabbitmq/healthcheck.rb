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
          port = @configuration.local_port

          connection = Bunny.new("amqp://localhost:#{port}", log_file: devnull)
          connection.start
          connection.stop
        end
      end
    end
  end
end
