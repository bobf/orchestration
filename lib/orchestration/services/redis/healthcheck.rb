# frozen_string_literal: true

module Orchestration
  module Services
    module Redis
      class Healthcheck
        class NotConnectedError < OrchestrationError; end

        include HealthcheckBase

        dependencies 'redis'

        def connection_errors
          [NotConnectedError]
        end

        def connect
          host = @configuration.host
          port = @configuration.port
          return if ::Redis.new(url: "redis://#{host}:#{port}").connected?

          raise NotConnectedError
        end
      end
    end
  end
end
