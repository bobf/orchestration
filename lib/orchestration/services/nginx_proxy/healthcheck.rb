# frozen_string_literal: true

module Orchestration
  module Services
    module NginxProxy
      class Healthcheck
        include HealthcheckBase

        def initialize(env)
          @configuration = Configuration.new(env)
        end

        def connect
          Net::HTTP.start('localhost', 3000)
        end

        def connection_errors
          [Errno::ECONNREFUSED]
        end
      end
    end
  end
end
