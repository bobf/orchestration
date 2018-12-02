# frozen_string_literal: true

module Orchestration
  module Services
    module Mongo
      class Configuration
        include ConfigurationBase

        self.service_name = 'mongo'

        def initialize(env)
          @env = env
          @settings = nil
          return unless defined?(Mongoid)
          return unless File.exist?(@env.mongoid_configuration_path)

          @settings = config.fetch(@env.environment)
        end

        def friendly_config
          "[mongoid] #{host}:#{local_port}"
        end

        private

        def config
          YAML.safe_load(
            File.read(@env.mongoid_configuration_path), [], [], true
          )
        end
      end
    end
  end
end
