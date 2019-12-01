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
          "[mongoid] #{host}:#{port}/#{database}"
        end

        def port
          return url_config[:port] unless url_config.nil?

          DockerCompose::MongoService::PORT
        end

        def host
          return url_config[:host] unless url_config.nil?

          super
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

        def url_config
          return nil unless ENV.key?('MONGO_URL')

          host, _, port = ENV['MONGO_URL'].rpartition('/').first.partition(':')
          _, _, database = ENV['MONGO_URL'].rpartition('/')
          { host: host, port: port.empty? ? '27017' : port, database: database }
        end

        def database
          return url_config[:database] unless url_config.nil?

          env_config = config.fetch(@env.environment)
          return env_config.fetch('database') if env_config.key?('database')

          bad_config_error if clients_key.nil?
          merged_config(env_config)
        end

        def merged_config(env_config)
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
