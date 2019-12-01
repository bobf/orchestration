# frozen_string_literal: true

module Orchestration
  module DockerCompose
    class DatabaseService
      # We dictate which port all database services will run on in their
      # container to simplify port mapping.
      PORT = 3354

      def initialize(config, environment)
        @environment = environment
        @config = config
      end

      def definition
        return nil if @config.settings.nil?
        return nil if @config.adapter.name == 'sqlite3'

        {
          'image' => @config.adapter.image,
          'environment' => @config.adapter.environment
        }.merge(ports).merge(volumes)
      end

      private

      def volume
        @config.env.database_volume
      end

      def ports
        return {} unless %i[development test].include?(@environment)

        { 'ports' => ["#{@config.settings.fetch('port')}:#{PORT}"] }
      end

      def volumes
        return {} if @environment == :test

        { 'volumes' => ["#{volume}:#{@config.adapter.data_dir}"] }
      end
    end
  end
end
