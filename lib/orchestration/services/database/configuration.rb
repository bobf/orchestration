# frozen_string_literal: true

module Orchestration
  module Services
    module Database
      class Configuration
        include ConfigurationBase

        self.service_name = 'database'

        def enabled?
          defined?(::ActiveRecord)
        end

        def friendly_config
          return "[#{adapter.name}]" if sqlite?

          "[#{adapter.name}] #{adapter.name}://#{username}:#{password}@#{host}:#{port}/#{database}"
        end

        def settings(healthcheck: false)
          {
            adapter: adapter.name,
            host:,
            port:,
            username:,
            password:,
            database: healthcheck ? adapter.credentials['database'] : database
          }.transform_keys(&:to_s)
        end

        def configured?
          sqlite? || super
        end

        def console_command
          adapter.console_command
        end

        def adapter
          url_adapter = url_config['adapter']
          file_adapter = file_config['adapter']

          return adapter_by_name(url_adapter) unless url_adapter.nil?
          return adapter_by_name(file_adapter) unless file_adapter.nil?
          return adapter_by_name('sqlite3') if defined?(SQLite3)

          nil
        end

        private

        def custom?
          !@options[:config_path].nil?
        end

        def database_configuration_path
          return @env.database_configuration_path unless custom?

          @options[:config_path]
        end

        def file_config
          return {} unless File.exist?(database_configuration_path) || custom?

          yaml = ERB.new(File.read(database_configuration_path)).result
          YAML.safe_load(yaml, aliases: true)[@env.environment] || {}
        end

        def url_config
          url = file_config['url'] || env.database_url
          return {} if url.nil?

          config = DatabaseUrl.to_active_record_hash(url)
                             &.transform_keys(&:to_s)

          # A quirk of DatabaseUrl is that if no "/path" is present then the
          # `database` component is an empty string. In this unique case, we
          # want `nil` instead so that we can delegate to a default.
          config['database'] = nil if database_missing?(config)
          config
        end

        def database_missing?(config)
          config.key?('database') && config['database'].empty?
        end

        def host
          chained_config('host') || super
        end

        def port
          return nil if sqlite?

          chained_config('port') || super
        end

        def username
          chained_config('username') || (adapter && adapter.credentials['username'])
        end

        def password
          chained_config('password') || (adapter && adapter.credentials['password'])
        end

        def database
          chained_config('database') || (adapter && adapter.credentials['database'])
        end

        def chained_config(key)
          return url_config[key] || file_config[key] if @env.environment == 'test'

          file_config[key] || url_config[key]
        end

        def adapter_by_name(name)
          {
            'mysql2' => adapters::Mysql2,
            'mysql' => adapters::Mysql2,
            'postgresql' => adapters::Postgresql,
            'postgis' => adapters::Postgis,
            'sqlite3' => adapters::Sqlite3
          }.fetch(name).new(self)
        rescue KeyError
          Orchestration.error('database.unknown_adapter', adapter: name.inspect)
          raise
        end

        def adapters
          Orchestration::Services::Database::Adapters
        end

        def sqlite?
          adapter.name == 'sqlite3'
        end
      end
    end
  end
end
