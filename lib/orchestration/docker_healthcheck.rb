# frozen_string_literal: true

require 'net/http'
module Orchestration
  class DockerHealthcheck
    def self.execute
      new.execute
    end

    def execute
      return_code = 1

      # rubocop:disable Lint/RescueException
      begin
        response = run
        return_code = 0 if success?(response.code)
        puts message(response.code)
      rescue Exception => e
        puts "[#{__FILE__}] ERROR: #{e.inspect}"
      ensure
        exit return_code
      end
      # rubocop:enable Lint/RescueException
    end

    private

    def run
      client = Net::HTTP.new(
        ENV.fetch('WEB_HOST', 'localhost'),
        ENV.fetch('WEB_PORT', '8080').to_i
      )

      client.read_timeout = ENV.fetch('WEB_HEALTHCHECK_READ_TIMEOUT', '10').to_i
      client.open_timeout = ENV.fetch('WEB_HEALTHCHECK_OPEN_TIMEOUT', '10').to_i

      client.start do |request|
        request.get(ENV.fetch('WEB_HEALTHCHECK_PATH') { '/' })
      end
    end

    def success_codes
      ENV.fetch('WEB_HEALTHCHECK_SUCCESS_CODES', '200,201,202,204').split(',')
    end

    def success?(code)
      success_codes.include?(code.to_s)
    end

    def message(code)
      if success?(code)
        outcome = 'SUCCESS ✓ '
        in_or_not = 'IN'
      else
        outcome = 'FAILURE ✘ '
        in_or_not = 'NOT IN'
      end

      accepted = success_codes.join(', ')
      message = "#{in_or_not} [#{accepted}] : #{outcome} [#{__FILE__}]"

      "# HTTP_STATUS(#{code}) #{message}"
    end
  end
end
