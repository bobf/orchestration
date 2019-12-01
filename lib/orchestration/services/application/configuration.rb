# frozen_string_literal: true

module Orchestration
  module Services
    module Application
      class Configuration
        include ConfigurationBase

        self.service_name = 'application'

        def initialize(env, service_name = nil)
          super
          @settings = {} # Included for interface consistency; currently unused.
        end

        def docker_username
          @env.settings.get('docker.username')
        end

        def application_name
          @env.settings.get('docker.repository')
        end

        def friendly_config
          "[#{application_name}] #{host}:#{local_port}"
        end

        def database_settings
          Database::Configuration.new(@env).settings
        end

        def database_url
          settings = database_settings
          return nil if settings.fetch('adapter') == 'sqlite3'

          scheme = settings.fetch('scheme')
          database = settings.fetch('database')
          username = settings.fetch('username')
          password = settings.fetch('password')
          port = DockerCompose::DatabaseService::PORT
          host = Database::Configuration.service_name

          "#{scheme}://#{username}:#{password}@#{host}:#{port}/#{database}"
        end
      end
    end
  end
end
