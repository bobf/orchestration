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

        def modify_environment
          @database_url = ENV.delete('DATABASE_URL')
          @development_database_url = ENV.delete('DEVELOPMENT_DATABASE_URL')
          @test_database_url = ENV.delete('TEST_DATABASE_URL')
        end

        def unmodify_environment
          ENV['DATABASE_URL'] = @database_url
          ENV['DEVELOPMENT_DATABASE_URL'] = @development_database_url
          ENV['TEST_DATABASE_URL'] = @test_database_url
        end

        private

        def adapter_errors
          @configuration.adapter.errors
        end

        def settings
          @configuration.settings(healthcheck: true)
        end
      end
    end
  end
end
