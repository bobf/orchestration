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

        adapter = @config.adapter
        return nil if adapter.name == 'sqlite3'

        port = @config.settings.fetch('port')
        {
          'image' => adapter.image,
          'environment' => adapter.environment,
          'volumes' => ["#{volume}:#{adapter.data_dir}"],
          'ports' => ["#{port}:#{PORT}"]
        }
      end

      private

      def volume
        @config.env.database_volume
      end
    end
  end
end
