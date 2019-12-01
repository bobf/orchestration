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
          "[#{@service_name}] #{host}:#{local_port}"
        end
      end
    end
  end
end
