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
          return "[#{@adapter.name}]" if @adapter.name == 'sqlite3'

          "[#{@adapter.name}] #{host}:#{local_port}"
        end

        private

        def setup
          @adapter = adapter_for(base['adapter'])
          @settings = merged_settings
          return if @adapter.name == 'sqlite3'
          return unless %w[test development].include?(@env.environment)

          @settings.merge!('port' => local_port) if @env.docker_compose_config?
        end

        def merged_settings
          base.merge(@adapter.credentials)
              .merge('scheme' => base['adapter'],
                     'port' => DockerCompose::DatabaseService::PORT)
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

        def adapter_for(name)
          {
            'mysql2' => adapters::Mysql2,
            'postgresql' => adapters::Postgresql,
            'sqlite3' => adapters::Sqlite3
          }.fetch(name).new
        end

        def environment
          @environments.fetch(@env.environment)
        rescue KeyError
          raise UnknownEnvironmentError,
                I18n.t(
                  'orchestration.database.unknown_environment',
                  environment: @env.environment
                )
        end

        def base
          environment.merge(url_config).merge('host' => host)
        end

        def host
          return nil if @adapter&.name == 'sqlite3'

          super
        end

        def adapters
          Orchestration::Services::Database::Adapters
        end

        def default_port
          return {} if @adapter.name == 'sqlite3'

          { 'port' => @adapter.default_port }
        end

        def url_config
          return {} if @env.database_url.nil?

          uri = URI.parse(@env.database_url)

          {
            'host' => uri.hostname,
            'adapter' => uri.scheme,
            'port' => uri.port
          }.merge(query_params(uri))
        end

        def query_params(uri)
          return {} if uri.query.nil?

          Hash[URI.decode_www_form(uri.query)]
        end
      end
    end
  end
end
