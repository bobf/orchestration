# frozen_string_literal: true

module Orchestration
  module Services
    module Listener
      class Healthcheck
        include HealthcheckBase

        def connect
          Net::HTTP.start(@configuration.host, @configuration.port)
        end

        def connection_errors
          [Errno::ECONNREFUSED, Errno::EADDRNOTAVAIL]
        end
      end
    end
  end
end
