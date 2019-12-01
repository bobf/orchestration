# frozen_string_literal: true

module Orchestration
  module DockerCompose
    class MongoService
      PORT = 27_020

      def initialize(config, environment)
        @config = config
        @environment = environment
      end

      def definition
        return nil unless @config.enabled?

        { 'image' => 'library/mongo' }.merge(ports).merge(volumes)
      end

      private

      def ports
        return {} unless %i[development test].include?(@environment)

        { 'ports' => ["#{local_port}:#{remote_port}"] }
      end

      def volumes
        return {} if @environment == :test

        { 'volumes' => ["#{@config.env.mongo_volume(@environment)}:/data/db"] }
      end

      def client
        Services::Mong::Configuration::CONFIG_KEYS.each do |key|
          return @config.settings.fetch(key) if @config.settings.key?(key)
        end
      end

      def local_port
        Orchestration.random_local_port
      end

      def remote_port
        Orchestration::Services::Mongo::PORT
      end
    end
  end
end
