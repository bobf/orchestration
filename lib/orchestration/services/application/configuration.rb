module Orchestration
  module Services
    module Application
      class Configuration
        def initialize(env)
          @env = env
        end

        def environment
          @env
        end

        def database_settings
          Database::Configuration.new(@env).settings
        end
      end
    end
  end
end
