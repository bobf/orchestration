# frozen_string_literal: true

module Orchestration
  module Services
    module Mongo
      class Healthcheck
        include HealthcheckBase

        dependencies 'mongoid'

        def connection_errors
          return [Moped::Errors::ConnectionFailure] if defined?(Moped)

          [::Mongo::Error::NoServerAvailable]
        end

        def connect
          silence_warnings

          # REVIEW: For some reason this is extremely slow. Worth trying
          # to see if there's a faster way to fail.
          Mongoid.load_configuration(@configuration.settings)
          !default_client.database_names.empty?
        end

        private

        def default_client
          return Mongoid.default_client if Mongoid.respond_to?(:default_client)

          # Support older versions of Mongoid
          Mongoid.default_session
        end

        def silence_warnings
          if defined?(Moped)
            Moped.logger = Logger.new(devnull)
          else
            Mongoid.logger = Logger.new(devnull)
          end
        end
      end
    end
  end
end
