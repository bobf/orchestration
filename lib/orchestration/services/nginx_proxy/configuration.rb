# frozen_string_literal: true

module Orchestration
  module Services
    module NginxProxy
      class Configuration
        include ConfigurationBase

        self.service_name = 'nginx-proxy'

        def initialize(env)
          @env = env
        end

        def friendly_config
          "[nginx-proxy] #{host}:#{local_port}"
        end
      end
    end
  end
end
