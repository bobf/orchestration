# frozen_string_literal: true

module Orchestration
  module DockerCompose
    class ApplicationService
      PORT = 3000

      def initialize(config)
        @config = config
        @env = config.environment
      end

      def definition
        {
          'image' => image,
          'environment' => environment,
          'ports' => ["#{PORT}:#{PORT}"]
        }
      end

      private

      def image
        "#{@env.settings.get('docker.username')}/#{@env.application_name}"
      end

      def environment
        {
          'DATABASE_URL' => database_url,
          'SECRET_KEY_BASE' => nil,
          'RAILS_LOG_TO_STDOUT' => '1'
        }
      end

      def database_url
        settings = @config.database_settings
        return nil if settings.fetch('adapter') == 'sqlite3'

        scheme = settings.fetch('scheme')
        database = settings.fetch('database')
        username = settings.fetch('username')
        password = settings.fetch('password')
        port = DatabaseService::PORT

        "#{scheme}://#{username}:#{password}@database:#{port}/#{database}"
      end
    end
  end
end
