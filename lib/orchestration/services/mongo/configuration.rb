# frozen_string_literal: true

module Orchestration
  module Services
    module Mongo
      class Configuration
        include ConfigurationBase

        self.service_name = 'mongo'

        def enabled?
          defined?(::Mongoid)
        end

        def friendly_config
          "[mongoid] mongodb://#{host}:#{port}/#{database}"
        end

        def database
          return url_config['database'] unless @env.mongo_url.nil?

          file_config.fetch('database', default_database)
        end

        def host
          return url_config['host'] unless @env.mongo_url.nil?

          super
        end

        def port
          return url_config['port'] unless @env.mongo_url.nil?

          super
        end

        private

        def default_database
          "#{@env.environment}db"
        end

        def url_config
          uri = URI.parse(@env.mongo_url)
          raise ArgumentError, 'MONGO_URL protocol must be mongodb://' unless uri.scheme == 'mongodb'

          url_config_structure(uri)
        end

        def url_config_structure(uri)
          hosts = uri.host.split(',')
          database = uri.path.partition('/').last

          {
            'user' => uri.user,
            'password' => uri.password,
            'host' => hosts.first,
            'port' => uri.port || Services::Mongo::PORT,
            'database' => database == '' ? default_database : database
          }
        end

        def file_config
          return {} unless File.exist?(@env.mongoid_configuration_path)

          yaml = File.read(@env.mongoid_configuration_path)
          config = YAML.safe_load(yaml, [], [], true)
          env = config.fetch(@env.environment, nil)
          return {} if env.nil?

          env.fetch('clients', env.fetch('sessions', {})).fetch('default', {})
        end
      end
    end
  end
end
