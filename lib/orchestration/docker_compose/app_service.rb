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
          'image' => '${DOCKER_ORGANIZATION}/${DOCKER_REPOSITORY}',
          'environment' => environment
        }
      end

      private

      def environment
        {
          'RAILS_LOG_TO_STDOUT' => '1',
          'RAILS_SERVE_STATIC_FILES' => '1',
          'UNICORN_PRELOAD_APP' => '1',
          'UNICORN_TIMEOUT' => '60',
          'UNICORN_WORKER_PROCESSES' => '8',
          'SERVICE_PORTS' => '8080'
        }.merge(inherited_environment)
      end

      def inherited_environment
        {
          'DATABASE_URL' => nil,
          'HOST_UID' => nil,
          'RAILS_ENV' => nil,
          'SECRET_KEY_BASE' => nil,
          'VIRTUAL_HOST' => nil
        }
      end
    end
  end
end
