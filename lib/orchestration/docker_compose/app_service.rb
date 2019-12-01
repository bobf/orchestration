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
        '${DOCKER_ORGANIZATION}/${DOCKER_REPOSITORY}:${DOCKER_TAG}'
      end

      def environment
        {
          'RAILS_LOG_TO_STDOUT' => '1',
          'RAILS_SERVE_STATIC_FILES' => '1',
          'WEB_PRELOAD_APP' => '1'
        }.merge(Hash[inherited_environment.map { |key| [key, nil] }])
      end

      def inherited_environment
        [
          'DATABASE_URL',
          'HOST_UID',
          'RAILS_ENV',
          'SECRET_KEY_BASE',
          'WEB_CONCURRENCY',
          'WEB_TIMEOUT',
          'WEB_WORKER_PROCESSES'
        ]
      end

      def ports
        ['${LISTEN_PORT}:8080']
      end
    end
  end
end
