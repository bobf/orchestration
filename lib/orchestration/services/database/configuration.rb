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

          if ENV.key?('DATABASE_URL')
            config = DatabaseUrl.to_active_record_hash
            host = config.fetch('host', '127.0.0.1')
            port = config.fetch('port', compose.local_port('database'))
          else
            host = '127.0.0.1'
            port = compose.local_port('database')
          end

          "[#{adapter.name}] #{host}:#{port}"
        end

        def adapter
          return adapter_for('postgresql') if defined?(PG)
          return adapter_for('mysql2') if defined?(Mysql2)
          return adapter_for('sqlite3') if defined?(SQLite3)

          nil
        end

        private

        def adapter_for(name)
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
