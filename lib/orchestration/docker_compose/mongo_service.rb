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
        return nil if @config.settings.nil?

        { 'image' => 'library/mongo' }.merge(ports).merge(volumes)
      end

      private

      def ports
        return {} unless %i[development test].include?(@environment)

        { 'ports' => ["#{local_port}:#{remote_port}"] }
      end

      def volumes
        return {} if @environment == :test

        { 'volumes' => ["#{@config.env.mongo_volume}:/data/db"] }
      end

      def local_port
        _host, _, port = clients.fetch('default')
                                .fetch('hosts')
                                .first
                                .partition(':')
        port.empty? ? remote_port : port
      end

      def clients
        @config.settings.fetch('clients')
      rescue KeyError
        @config.settings.fetch('sessions')
      end

      def remote_port
        Orchestration::Services::Mongo::PORT
      end
    end
  end
end
