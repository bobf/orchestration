# frozen_string_literal: true

module Orchestration
  module Services
    module App
      class Healthcheck
        include HealthcheckBase

        def connect
          response = Net::HTTP.get_response(
            URI("http://localhost:#{@configuration.local_port}")
          )
          connection_error(response.code) if connection_error?(response.code)
        end

        def connection_errors
          [Errno::ECONNREFUSED, AppConnectionError]
        end

        private

        def connection_error(code)
          raise AppConnectionError,
                I18n.t('orchestration.app.connection_error', code: code)
        end

        def connection_error?(code)
          %w[502 503 500].include?(code)
        end
      end
    end
  end
end
