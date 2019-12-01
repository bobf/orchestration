# frozen_string_literal: true

module Orchestration
  module DockerCompose
    class ApplicationService
      def initialize(config)
        @config = config
      end

      def definition
        {
          'image' => image,
          'environment' => environment,
          'expose' => [8080]
        }
      end

      private

      def image
        "#{@config.docker_username}/#{@config.application_name}"
      end

      def environment
        {
          'DATABASE_URL' => @config.database_url,
          'RAILS_LOG_TO_STDOUT' => '1',
          'UNICORN_PRELOAD_APP' => '1',
          'UNICORN_TIMEOUT' => '60',
          'UNICORN_WORKER_PROCESSES' => '8',
          'VIRTUAL_PORT' => '8080',
          'VIRTUAL_HOST' => 'localhost'
        }.merge(inherited_environment)
      end

      def inherited_environment
        {
          'HOST_UID' => nil,
          'RAILS_ENV' => nil,
          'SECRET_KEY_BASE' => nil
        }
      end
    end
  end
end
