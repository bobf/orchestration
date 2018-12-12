# frozen_string_literal: true

module Orchestration
  module Services
    module Database
      class Configuration
        include ConfigurationBase

        self.service_name = 'database'

        attr_reader :adapter

        def initialize(env, service_name = nil)
          super
          @adapter = nil
          @settings = nil
          return unless defined?(ActiveRecord)
          return unless File.exist?(@env.database_configuration_path)

          @environments = parse(File.read(@env.database_configuration_path))
          setup
        end

        def friendly_config
          adapter = @settings.fetch('adapter')
          return "[#{adapter}]" if adapter == 'sqlite3'

          "[#{adapter}] #{host}:#{local_port}"
        end

        private

        def setup
          @adapter = adapter_object(base['adapter'])
          @settings = base.merge(@adapter.credentials)
                          .merge(
                            'scheme' => scheme_name(base['adapter']),
                            'port' => DockerCompose::DatabaseService::PORT
                          )
        end

        def parse(content)
          yaml(erb(content))
        end

        def erb(content)
          ERB.new(content).result
        end

        def yaml(content)
          YAML.safe_load(content, [], [], true) # true: Allow aliases
        end

        def adapter_object(name)
          {
            'mysql2' => adapters::Mysql2,
            'postgresql' => adapters::Postgresql,
            'sqlite3' => adapters::Sqlite3
          }.fetch(name).new
        end

        def environment
          @environments[@env.environment]
        end

        def base
          environment.merge(url_config).merge('host' => host)
        end

        def host
          return nil if @adapter.is_a?(adapters::Sqlite3)

          super
        end

        def adapters
          Orchestration::Services::Database::Adapters
        end

        def default_port
          return {} if @adapter.is_a?(adapters::Sqlite3)

          { 'port' => @adapter.default_port }
        end

        def url_config
          return {} if @env.database_url.nil?

          uri = URI.parse(@env.database_url)

          {
            'host' => uri.hostname,
            'adapter' => adapter_name(uri.scheme),
            'port' => uri.port
          }.merge(query_params(uri))
        end

        def scheme_name(adapter_name)
          adapter_mapping.invert.fetch(adapter_name)
        end

        def adapter_name(scheme)
          name = adapter_mapping.fetch(scheme, nil)

          return name unless name.nil?

          raise ArgumentError,
                I18n.t('orchestration.unknown_scheme', scheme: scheme)
        end

        def query_params(uri)
          return {} if uri.query.nil?

          Hash[URI.decode_www_form(uri.query)]
        end

        def adapter_mapping
          {
            'mysql' => 'mysql2',
            'postgres' => 'postgresql',
            'sqlite3' => 'sqlite3'
          }
        end
      end
    end
  end
end
