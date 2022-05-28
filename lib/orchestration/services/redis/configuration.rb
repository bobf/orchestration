# frozen_string_literal: true

module Orchestration
  module Services
    module Redis
      class Configuration
        include ConfigurationBase

        self.service_name = 'redis'

        def enabled?
          defined?(::Redis)
        end

        def friendly_config
          "[redis] redis://#{host}:#{port}"
        end

        def host
          from_url['host'] || super
        end

        def port
          from_url['port'] || super
        end

        private

        def from_url
          return {} if @env.redis_url.nil?

          uri = URI.parse(@env.redis_url)
          { 'host' => uri.host, 'port' => uri.port || PORT }
        end
      end
    end
  end
end
