# frozen_string_literal: true

module Orchestration
  module Services
    module Application
      class Configuration
        attr_reader :settings

        def initialize(env)
          @env = env
          @settings = {} # Included for interface consistency; currently unused.
        end

        def environment
          @env
        end

        def friendly_config
          "[#{@env.application_name}]"
        end

        def database_settings
          Database::Configuration.new(@env).settings
        end
      end
    end
  end
end
