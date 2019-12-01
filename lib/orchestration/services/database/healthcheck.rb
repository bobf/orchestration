# frozen_string_literal: true

module Orchestration
  module Services
    module Database
      class Healthcheck
        include HealthcheckBase

        dependencies 'active_record'

        def connect
          return if settings[:adapter] == 'sqlite3'

          ActiveRecord::Base.establish_connection(settings)
          ActiveRecord::Base.connection
        end

        def connection_errors
          [ActiveRecord::ConnectionNotEstablished].concat(adapter_errors)
        end

        private

        def adapter_errors
          @configuration.adapter.errors
        end

        def settings
          @configuration.settings
        end
      end
    end
  end
end
