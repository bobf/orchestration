# frozen_string_literal: true

module Orchestration
  module DockerCompose
    class MongoService
      def initialize(config)
        @config = config
      end

      def definition
        return nil if @config.settings.nil?

        # REVIEW: If the host application defines multiple mongo hosts then we
        # create one service instance and point them all at the same service.
        # Instead we should probably create a separate service for each.
        ports = @config.ports.map do |port|
          "#{port}:#{Orchestration::Services::Mongo::PORT}"
        end

        {
          'image' => 'library/mongo',
          'ports' => ports
        }
      end
    end
  end
end
