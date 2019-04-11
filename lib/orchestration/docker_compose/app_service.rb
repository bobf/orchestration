# frozen_string_literal: true

module Orchestration
  module DockerCompose
    class AppService
      def initialize(config, environment)
        @environment = environment
        @config = config
      end

      def definition
        {
          'image' => image,
          'environment' => environment,
          'ports' => ports,
          'deploy' => {
            'mode' => 'replicated',
            'replicas' => '${REPLICAS}'
          }
        }
      end

      private

      def image
        '${DOCKER_ORGANIZATION}/${DOCKER_REPOSITORY}'
      end

      def environment
        {
          'RAILS_LOG_TO_STDOUT' => '1',
          'RAILS_SERVE_STATIC_FILES' => '1',
          'UNICORN_PRELOAD_APP' => '1',
          'UNICORN_TIMEOUT' => '60',
          'UNICORN_WORKER_PROCESSES' => '8'
        }.merge(inherited_environment)
      end

      def inherited_environment
        {
          'DATABASE_URL' => nil,
          'HOST_UID' => nil,
          'RAILS_ENV' => nil,
          'SECRET_KEY_BASE' => nil
        }
      end

      def ports
        ['${LISTEN_PORT}:8080']
      end
    end
  end
end
