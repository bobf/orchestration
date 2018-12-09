# frozen_string_literal: true

module Orchestration
  module Services
    module Listener
      class Healthcheck
        include HealthcheckBase

        def connect
          Net::HTTP.start('localhost', @configuration.local_port)
        end

        def connection_errors
          [Errno::ECONNREFUSED]
        end
      end
    end
  end
end
