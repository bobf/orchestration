# frozen_string_literal: true

module Orchestration
  class ServiceCheck
    ATTEMPT_LIMIT = 10
    RETRY_INTERVAL = 3 # seconds

    def initialize(service, terminal, options = {})
      @service = service
      @service_name = service_name(service)
      @terminal = terminal
      @attempt_limit = options.fetch(:attempt_limit, ATTEMPT_LIMIT)
      @retry_interval = options.fetch(:retry_interval, RETRY_INTERVAL)
      @attempts = 0
      @failure_callback = options.fetch(:failure_callback, nil)
    end

    def run
      echo_start
      success = attempt_connection
      echo_ready if success
      success
    end

    private

    def attempt_connection
      echo_waiting
      @service.connect
      true
    rescue *@service.connection_errors => e
      @attempts += 1
      sleep @retry_interval
      retry unless @attempts == @attempt_limit
      echo_error(e)
      echo_failure
      false
    end

    def echo_start
      @terminal.write(@service_name.to_sym, '', :status)
    end

    def echo_waiting
      @terminal.write(
        :waiting,
        I18n.t(
          "orchestration.#{@service_name}.waiting",
          config: @service.configuration.friendly_config
        )
      )
    end

    def echo_ready
      @terminal.write(
        :ready,
        I18n.t(
          "orchestration.#{@service_name}.ready",
          config: @service.configuration.friendly_config
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
      @terminal.write(:error, "[#{error.class.name}] #{error.message}")
    end

    def service_name(service)
      # e.g.:
      # Orchestration::Services::RabbitMQ::Healthcheck => 'rabbitmq'
      service.class.name.split('::')[-2].downcase
    end
  end
end
