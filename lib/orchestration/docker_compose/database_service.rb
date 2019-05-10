# frozen_string_literal: true

module Orchestration
  module DockerCompose
    class DatabaseService
      def initialize(config, environment)
        @environment = environment
        @config = config
      end

      def definition
        return nil unless @config.enabled?
        return nil if @config.adapter.name == 'sqlite3'

        {
          'image' => @config.adapter.image,
          'environment' => @config.adapter.environment,
          'volumes' => volumes
        }.merge(ports).merge(volumes)
      end

      private

      def volume
        @config.env.database_volume(@environment)
      end

      def remote_port
        @config.adapter.default_port
      end

      def ports
        return {} unless %i[development test].include?(@environment)

        { 'ports' => ["#{Orchestration.random_local_port}:#{remote_port}"] }
      end

      def volumes
        return {} if @environment == :test

        { 'volumes' => ["#{volume}:#{@config.adapter.data_dir}"] }
      end
    end
  end
end
