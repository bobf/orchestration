# frozen_string_literal: true

module Orchestration
  module Services
    module Mongo
      class Healthcheck
        include HealthcheckBase

        def initialize(env)
          @configuration = Configuration.new(env)
        end

        def connection_errors
          [::Mongo::Error::NoServerAvailable]
        end

        def connect
          # REVIEW: For some reason this is extremely slow. Worth trying
          # to see if there's a faster way to fail.
          Mongoid.load_configuration(@configuration.settings)
          !Mongoid.default_client.database_names.empty?
        end

        private

        def clients
          return Mongoid.sessions if Mongoid.respond_to?(:sessions)

          Mongoid.clients
        end
      end
    end
  end
end
