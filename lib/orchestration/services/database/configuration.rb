# frozen_string_literal: true

module Orchestration
  module Services
    module Database
      class Configuration
        include ConfigurationBase

        self.service_name = 'database'

        def enabled?
          !adapter.nil?
        end

        def friendly_config
          return "[#{adapter.name}]" if adapter.name == 'sqlite3'

          "[#{adapter.name}] #{host}:#{port}"
        end

        def settings
          { adapter: adapter.name, host: host, port: port }
        end

        def adapter
          url = url_config['adapter']
          file = file_config['adapter']

          return adapter_by_name(url) unless url.nil?
          return adapter_by_name(file) unless file.nil?
          return adapter_by_name('sqlite3') if defined?(SQLite3)

          nil
        end

        private

        def file_config
          return {} unless File.exist?(@env.database_configuration_path)

          yaml = File.read(env.database_configuration_path)
          YAML.safe_load(yaml, [], [], true)[@env.environment]
        end

        def url_config
          return {} if env.database_url.nil?

          DatabaseUrl.to_active_record_hash(env.database_url).stringify_keys
        end

        def host
          url_config[:host] || super
        end

        def port
          url_config[:port] || super
        end

        def adapter_by_name(name)
          {
            'mysql2' => adapters::Mysql2,
            'mysql' => adapters::Mysql2,
            'postgresql' => adapters::Postgresql,
            'sqlite3' => adapters::Sqlite3
          }.fetch(name).new
        rescue KeyError
          Orchestration.error('database.unknown_adapter', adapter: name.inspect)
          raise
        end

        def adapters
          Orchestration::Services::Database::Adapters
        end
      end
    end
  end
end
