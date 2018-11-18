# frozen_string_literal: true

module Orchestration
  module DockerCompose
    PORT = 3354

    class DatabaseService
      def initialize(config)
        @config = config
      end

      def definition
        adapter = @config.settings['adapter']
        return nil if adapter == 'sqlite3'

        {
          'image' => image_from_adapter(adapter),
          'environment' => environment_from_adapter(adapter),
          'ports' => ["#{PORT}:#{PORT}"]
        }
      end

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
