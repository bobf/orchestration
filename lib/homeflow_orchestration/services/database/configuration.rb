# frozen_string_literal: true

module Orchestration
  module Services
    module Database
      class Configuration
        attr_reader :adapter, :settings

        def initialize(env)
          @env = env
          @adapter = nil
          return unless File.exist?(@env.database_configuration_path)

          environments = parse(File.read(@env.database_configuration_path))
          base = base_config(environments)
          @adapter = adapter_object(base['adapter'])
          @settings = base.merge(@adapter.credentials)
        end

        def friendly_config
          adapter = @settings['adapter']
          host = @settings['host']
          port = @settings['port']
          return "[#{adapter}]" if adapter == 'sqlite3'
          return "[#{adapter}] #{host}" unless port.present?

          "[#{adapter}] #{host}:#{port}"
        end

        private

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
          adapters = Orchestration::Services::Database::Adapters
          {
            'mysql2' => adapters::Mysql2,
            'postgresql' => adapters::Postgresql,
            'sqlite3' => adapters::Sqlite3
          }.fetch(name).new
        end

        def base_config(environments)
          missing_default unless environments.key?('default')

          host = url_config['host'] || environments[@env.environment]['host']

          environments['default']
            .merge(url_config)
            .merge('host' => host)
        end

        def url_config
          return {} if @env.database_url.nil?

          uri = URI.parse(@env.database_url)

          {
            'host' => uri.hostname,
            'adapter' => adapter_name_from_scheme(uri.scheme),
            'port' => uri.port
          }.merge(query_params(uri))
        end

        def adapter_name_from_scheme(scheme)
          return 'mysql2' if scheme == 'mysql'
          return 'postgresql' if scheme == 'postgres'
          return 'sqlite3' if scheme == 'sqlite3'

          raise ArgumentError,
                I18n.t('orchestration.unknown_scheme', scheme: scheme)
        end

        def query_params(uri)
          return {} if uri.query.nil?

          Hash[URI.decode_www_form(uri.query)]
        end

        def missing_default
          raise DatabaseConfigurationError,
                I18n.t('orchestration.database.missing_default')
        end
      end
    end
  end
end
