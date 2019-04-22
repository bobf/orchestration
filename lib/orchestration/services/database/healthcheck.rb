# frozen_string_literal: true

module Orchestration
  module Services
    module Database
      class Healthcheck
        include HealthcheckBase

        dependencies 'active_record'

        def connect
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
          return @configuration.settings unless @options[:init]

          {
            adapter: @configuration.adapter.name,
            port: DockerCompose::DatabaseService::PORT
          }.merge(@configuration.adapter.credentials)
        end
      end
    end
  end
end
