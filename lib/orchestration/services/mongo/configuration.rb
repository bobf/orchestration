# frozen_string_literal: true

module Orchestration
  module Services
    module Mongo
      class Configuration
        include ConfigurationBase

        self.service_name = 'mongo'

        def initialize(env, service_name = nil)
          super
          @settings = nil
          return unless defined?(Mongoid)
          return unless File.exist?(@env.mongoid_configuration_path)

          @settings = { clients_key => hosts_config }
        end

        def friendly_config
          "[mongoid] #{host}:#{local_port}/#{database}"
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
          config
            .fetch(@env.environment)
            .fetch(clients_key)
            .fetch('default')
            .fetch('database')
        end

        def port
          DockerCompose::MongoService::PORT
        end

        def clients_key
          return 'clients' if config.fetch(@env.environment).key?('clients')

          # Support older Mongoid versions
          'sessions'
        end

        def config
          @config ||= YAML.safe_load(
            File.read(@env.mongoid_configuration_path), [], [], true
          )
        end
      end
    end
  end
end
