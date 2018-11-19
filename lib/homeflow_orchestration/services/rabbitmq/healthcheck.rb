# frozen_string_literal: true

module HomeflowOrchestration
  module Services
    module RabbitMQ
      class Healthcheck
        include HealthcheckBase

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
          host = @configuration.settings.fetch('host')
          port = @configuration.settings.fetch('port')

          connection = Bunny.new("amqp://#{host}:#{port}", log_file: devnull)
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
