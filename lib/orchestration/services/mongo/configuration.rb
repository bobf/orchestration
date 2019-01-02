# frozen_string_literal: true

module Orchestration
  module Services
    module Mongo
      class Configuration
        include ConfigurationBase

        self.service_name = 'mongo'

        CONFIG_KEYS = %w[clients sessions hosts].freeze

        def initialize(env, service_name = nil)
          super
          @settings = nil
          return unless defined?(Mongoid)
          return unless File.exist?(@env.mongoid_configuration_path)

          @settings = if clients_key.nil?
                        hosts_config # Host was configured at top level.
                      else
                        { clients_key => hosts_config }
                      end
        end

        def friendly_config
          "[mongoid] #{host}:#{local_port}/#{database}"
        end

        def port
          DockerCompose::MongoService::PORT
        end

        private

        def hosts_config
          {
            'default' => {
              'hosts' => ["#{host}:#{port}"],
              'database' => database
            }
          }
        end

        def database
          env_config = config.fetch(@env.environment)
          return env_config.fetch('database') if env_config.key?('database')

          bad_config_error if clients_key.nil?

          env_config
            .fetch(clients_key)
            .fetch('default')
            .fetch('database')
        end

        def clients_key
          env_config = config.fetch(@env.environment)

          # Support older Mongoid versions
          CONFIG_KEYS.each do |key|
            return key if env_config.key?(key)
          end

          nil
        end

        def config
          @config ||= yaml(File.read(@env.mongoid_configuration_path))
        end

        def bad_config_error
          raise ArgumentError,
                I18n.t(
                  'orchestration.mongo.bad_config',
                  path: @env.mongoid_configuration_path,
                  expected: CONFIG_KEYS.join(', ')
                )
        end
      end
    end
  end
end
