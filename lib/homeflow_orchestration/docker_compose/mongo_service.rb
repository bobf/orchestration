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
          'ports' => ['27017:27017']
        }
      end
    end
  end
end
