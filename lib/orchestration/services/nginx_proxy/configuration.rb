# frozen_string_literal: true

module Orchestration
  module Services
    module NginxProxy
      class Configuration
        attr_reader :settings

        def initialize(env)
          @env = env
        end

        def friendly_config
          '[nginx-proxy]'
        end
      end
    end
  end
end
