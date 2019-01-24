# frozen_string_literal: true

module Orchestration
  module Services
    module HAProxy
      class Configuration
        include ConfigurationBase

        self.service_name = 'haproxy'

        def initialize(env, service_name = nil)
          super
          @settings = {}
        end

        def friendly_config
          "[haproxy] #{host}:#{local_port}"
        end
      end
    end
  end
end
