# frozen_string_literal: true

module Orchestration
  module DockerCompose
    class MongoService
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
        _host, _, port = @config.settings
                                .fetch('clients')
                                .fetch('default')
                                .fetch('hosts')
                                .first
                                .partition(':')
        port.empty? ? remote_port : port
      end

      def remote_port
        Orchestration::Services::Mongo::PORT
      end
    end
  end
end
