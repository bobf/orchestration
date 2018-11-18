# frozen_string_literal: true

module Orchestration
  module Services
    module Database
      class Healthcheck
        def self.start
          terminal = Terminal.new
          terminal.write(:database, nil, :status)
          new(terminal).start
        end

        def initialize(env, terminal)
          @env = env
          @attempts = 0
          @terminal = terminal
          @configuration = Database::Configuration.new(@env)
        end

        def start
          echo_waiting
          connect
          echo_ready
        rescue *connection_errors => e
          @attempts += 1
          sleep RETRY_INTERVAL
          retry unless @attempts == ATTEMPT_LIMIT
          echo_failure
          echo_error(e)
          exit 1
        end

        private

        def connect
          ActiveRecord::Base.establish_connection(@configuration.settings)
          ActiveRecord::Base.connection
        end

        def connection_errors
          [ActiveRecord::ConnectionNotEstablished].concat(adapter_errors)
        end

        def adapter_errors
          @configuration.adapter.errors
        end

        def echo_waiting
          @terminal.write(
            :waiting,
            I18n.t(
              'orchestration.database.waiting',
              config: @configuration.friendly_config
            )
          )
        end

        def echo_ready
          @terminal.write(
            :ready,
            I18n.t(
              'orchestration.database.ready',
              config: @configuration.friendly_config
            )
          )
        end

        def echo_failure
          @terminal.write(
            :failure,
            I18n.t('orchestration.attempt_limit', limit: ATTEMPT_LIMIT)
          )
        end

        def echo_error(error)
          @terminal.write(:error, error.message)
        end
      end
    end
  end
end
