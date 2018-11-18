# frozen_string_literal: true

module Orchestration
  module DockerCompose
    class DatabaseService
      # We dictate which port all database services will run on in their
      # container to simplify port mapping.
      PORT = 3354

      def initialize(config)
        @config = config
      end

      def definition
        return nil if @config.settings.nil?

        adapter = @config.settings.fetch('adapter')
        return nil if adapter == 'sqlite3'

        port = @config.settings.fetch('port')
        {
          'image' => image_from_adapter(adapter),
          'environment' => environment_from_adapter(adapter),
          'ports' => ["#{port}:#{PORT}"]
        }
      end

      private

      def image_from_adapter(adapter)
        {
          'postgresql' => 'library/postgres',
          'mysql2' => 'library/mysql'
        }.fetch(adapter)
      end

      def environment_from_adapter(adapter)
        {
          'postgresql' => {
            'PGPORT' => PORT.to_s,
            'POSTGRES_PASSWORD' => 'password'
          },
          'mysql2' => {
            'MYSQL_ROOT_PASSWORD' => 'password',
            'MYSQL_TCP_PORT' => PORT.to_s
          }
        }.fetch(adapter)
      end
    end
  end
end
