# frozen_string_literal: true

module Orchestration
  module Services
    module Mongo
      class Healthcheck
        def self.start
          terminal = Terminal.new
          terminal.write(:mongo, nil, :status)
          new(terminal).start
        end

        def initialize(env, terminal)
          @env = env
          @terminal = terminal
          @configuration = Mongo::Configuration.new(@env)
        end

        def start
          echo_waiting
          connect
          echo_ready
        rescue ArgumentError
          @attempts += 1
          sleep RETRY_INTERVAL
          retry unless @attempts == ATTEMPT_LIMIT
          echo_failure
          echo_error(e)
          exit 1
        end

        private

        def connect
          Mongoid.load_configuration(@configuration.settings['database'])
          Mongoid.default_client.database_names.present?
        end

        def clients
          return Mongoid.sessions if Mongoid.respond_to?(:sessions)

          Mongoid.clients
        end

        def database
          @configuration.settings['database']
        end

        def echo_waiting
          @terminal.write(
            :waiting,
            I18n.t(
              'orchestration.mongo.waiting',
              config: @configuration.friendly_config
            )
          )
        end

        def echo_ready
          @terminal.write(
            :ready,
            I18n.t('orchestration.mongo.ready')
          )
        end
      end
    end
  end
end
