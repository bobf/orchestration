# frozen_string_literal: true

module Orchestration
  class ServiceCheck
    ATTEMPT_LIMIT = ENV.fetch('ORCHESTRATION_RETRY_LIMIT', '10').to_i
    RETRY_INTERVAL = ENV.fetch('ORCHESTRATION_RETRY_INTERVAL', '6').to_i

    def initialize(service, terminal, options = {})
      @service = service
      @service_name = service.service_name
      @terminal = terminal
      @attempt_limit = options.fetch(:attempt_limit, ATTEMPT_LIMIT)
      @retry_interval = options.fetch(:retry_interval, RETRY_INTERVAL)
      @attempts = 0
      @failure_callback = options.fetch(:failure_callback, nil)
    end

    def run
      return echo_missing unless @service.configuration.configured?

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

    def echo_missing
      @terminal.write(
        @service_name.to_sym,
        "#{@service.configuration.error} (skipping)",
        :error
      )
    end

    def echo_start
      @terminal.write(@service_name.to_sym, '', :status)
    end

    def echo_waiting
      @terminal.write(:waiting, service_waiting)
    end

    def service_waiting
      I18n.t(
        "orchestration.#{@service_name}.waiting",
        config: friendly_config,
        default: default_waiting
      )
    end

    def default_waiting
      I18n.t(
        'orchestration.custom_service.waiting',
        config: friendly_config,
        service: @service_name
      )
    end

    def echo_ready
      @terminal.write(:ready, service_ready)
    end

    def service_ready
      I18n.t(
        "orchestration.#{@service_name}.ready",
        config: friendly_config,
        default: default_ready
      )
    end

    def default_ready
      I18n.t(
        'orchestration.custom_service.ready',
        config: friendly_config,
        service: @service_name
      )
    end

    def echo_failure
      @terminal.write(
        :failure,
        I18n.t('orchestration.attempt_limit', limit: @attempt_limit)
      )
    end

    def echo_error(error)
      @terminal.write(:error, "[#{error.class.name}] #{error.message}")
    end

    def friendly_config
      @service.configuration.friendly_config
    end
  end
end
