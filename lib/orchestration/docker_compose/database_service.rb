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
        return nil if adapter.name == 'sqlite3'

        {
          'image' => adapter.image,
          'environment' => adapter.environment
        }.merge(ports).merge(volumes)
      end

      private

      def adapter
        name = ComposeConfiguration.new(@environment).database_adapter_name
        base = 'Orchestration::Services::Database::Adapters'
        Object.const_get("#{base}::#{name.capitalize}").new
      end

      def remote_port
        adapter.default_port
      end

      def ports
        return {} unless %i[development test].include?(@environment)

        { 'ports' => ["#{Orchestration.random_local_port}:#{remote_port}"] }
      end

      def volumes
        return {} if @environment == :test

        { 'volumes' => ["#{@config.env.database_volume}:#{adapter.data_dir}"] }
      end
    end
  end
end
