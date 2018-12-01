# frozen_string_literal: true

module Orchestration
  module Services
    module Application
      class Configuration
        attr_reader :settings

        def initialize(env)
          @env = env
          @settings = {} # Included for interface consistency; currently unused.
        end

        def docker_username
          @env.settings.get('docker.username')
        end

        def application_name
          @env.application_name
        end

        def friendly_config
          "[#{application_name}]"
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

          "#{scheme}://#{username}:#{password}@database:#{port}/#{database}"
        end

        def local_port
          docker_compose_config
            .fetch('services')
            .fetch('nginx-proxy')
            .fetch('ports')
            .first
            .partition(':')
            .first
            .to_i
        end

        private

        def docker_compose_config
          YAML.safe_load(File.read(@env.docker_compose_configuration_path))
        end
      end
    end
  end
end
