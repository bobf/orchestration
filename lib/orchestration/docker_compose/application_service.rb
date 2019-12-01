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
          'entrypoint' => '/entrypoint.sh',
          'command' => %w[bundle exec unicorn],
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
          # `nil` values will inherit from environment or `.env` file.
          'HOST_UID' => nil,
          'RAILS_ENV' => nil,
          'SECRET_KEY_BASE' => nil,
          'DATABASE_URL' => database_url,
          'RAILS_LOG_TO_STDOUT' => '1',
          'UNICORN_SOCKET_DIR' => '/tmp/unicorn'
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
