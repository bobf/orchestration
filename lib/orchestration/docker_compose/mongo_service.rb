# frozen_string_literal: true

module Orchestration
  module DockerCompose
    class MongoService
      PORT = 27_020

      def initialize(config)
        @config = config
      end

      def definition
        return nil if @config.settings.nil?

        {
          'image' => 'library/mongo',
          'ports' => ["#{local_port}:#{remote_port}"]
        }
      end

      private

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
