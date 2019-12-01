# frozen_string_literal: true

module Orchestration
  module Services
    module RabbitMQ
      class Healthcheck
        include HealthcheckBase

        dependencies 'bunny'

        def initialize(env)
          @configuration = Configuration.new(env)
        end

        def connection_errors
          [
            Bunny::TCPConnectionFailedForAllHosts,
            AMQ::Protocol::EmptyResponseError
          ]
        end

        def connect
          port = @configuration.local_port

          connection = Bunny.new("amqp://localhost:#{port}", log_file: devnull)
          connection.start
          connection.stop
        end

        private

        def devnull
          File.open(File::NULL, 'w')
        end
      end
    end
  end
end
