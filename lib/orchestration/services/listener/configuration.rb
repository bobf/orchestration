# frozen_string_literal: true

module Orchestration
  module Services
    module Listener
      class Configuration
        include ConfigurationBase

        def self.service_name
          raise ArgumentError
        end

        def friendly_config
          "[#{image || @service_name}] #{host}:#{port}"
        end
      end
    end
  end
end
