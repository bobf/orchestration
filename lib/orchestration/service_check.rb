# frozen_string_literal: true

module Orchestration
  class ServiceCheck
    ATTEMPT_LIMIT = ENV.fetch('ORCHESTRATION_RETRY_LIMIT', '15').to_i
    RETRY_INTERVAL = ENV.fetch('ORCHESTRATION_RETRY_INTERVAL', '15').to_i

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
      return unless @service.configuration.configured?

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
      wait_failure(e)
      retry unless @attempts == @attempt_limit
      echo_error(e)
      echo_failure
      false
    end

    def wait_failure(error)
      @attempts += 1
      @last_error = error
      sleep @retry_interval
    end

    def last_error
      return nil if @last_error.nil?

      last_error_message
    end

    def last_error_message
      "(#{@last_error&.cause&.class&.name || @last_error&.class&.name})"
    end

    def echo_start
      @terminal.write(@service_name.to_sym, '', :status)
      @terminal.write(:config, friendly_config)
    end

    def echo_waiting
      @terminal.write(:waiting, last_error)
    end

    def echo_ready
      @terminal.write(:ready, service_ready)
    end

    def service_ready
      I18n.t('orchestration.service.ready', service: @service_name)
    end

    def echo_failure
      @terminal.write(:failure, I18n.t('orchestration.attempt_limit', limit: @attempt_limit))
    end

    def echo_error(error)
      cause = error.cause.nil? ? error : error.cause
      @terminal.write(:error, "[#{cause.class.name}] #{cause.message}")
    end

    def friendly_config
      @service.configuration.friendly_config
    end
  end
end
