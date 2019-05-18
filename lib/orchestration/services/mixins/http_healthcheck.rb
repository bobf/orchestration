module Orchestration
  module Services
    module HTTPHealthcheck
      def connect
        response = Net::HTTP.get_response(
          URI("http://#{@configuration.host}:#{@configuration.port}")
        )
        connection_error(response.code) if connection_error?(response.code)
        connection_error(response.code) unless connection_success?(response.code)
      end

      def connection_errors
        [Errno::ECONNREFUSED, HTTPConnectionError]
      end

      private

      def connection_error(code)
        raise HTTPConnectionError,
              I18n.t('orchestration.http.connection_error', code: code)
      end

      def connection_error?(code)
        %w[502 503 500].include?(code)
      end

      def connection_success?(code)
        # Override if specific success codes needed, otherwise default to true
        # (i.e. an error code [as defined above] was not returned so we assume
        # success).

        true
      end
    end
  end
end
