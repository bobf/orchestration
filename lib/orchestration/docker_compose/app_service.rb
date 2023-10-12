# frozen_string_literal: true

module Orchestration
  module DockerCompose
    class AppService
      include ComposeHelpers

      def initialize(config, environment)
        @environment = environment
        @config = config
      end

      class << self
        def command
          server = env.web_server
          %w[bundle exec] + case env.web_server
                            when 'puma'
                              %w[puma -C config/puma.rb]
                            when 'unicorn'
                              %w[unicorn -c config/unicorn.rb]
                            else
                              unsupported_web_server(server)
                            end
        end

        def entrypoint
          ["/app/#{orchestration}/entrypoint.sh"]
        end

        def healthcheck
          {
            'test' => ['/app/orchestration/healthcheck'],
            # Defaults according to
            # https://docs.docker.com/engine/reference/builder/#healthcheck
            # Except start_period which cannot be set to 0s
            'interval' => '30s',
            'timeout' => '30s',
            'start_period' => '5s',
            'retries' => 3
          }
        end

        private

        def orchestration
          env.orchestration_dir_name
        end

        def env
          @env ||= Environment.new
        end

        def unsupported_web_server(server)
          raise ArgumentError,
                I18n.t(
                  'orchestration.rake.app.unspported_web_server',
                  server: server,
                  expected: %w[puma unicorn]
                )
        end
      end

      def definition
        {
          'image' => image,
          'environment' => environment,
          'ports' => ports,
          'deploy' => deploy,
          'logging' => logging,
          'networks' => networks
        }
      end

      private

      def image
        '${DOCKER_ORGANIZATION}/${DOCKER_REPOSITORY}:${DOCKER_TAG}'
      end

      def deploy
        { 'mode' => 'replicated', 'replicas' => '${REPLICAS:-3}' }
      end

      def logging
        {
          'driver' => 'json-file',
          'options' => {
            'max-size' => '10m',
            'max-file' => '5'
          }
        }
      end

      def environment
        {
          'RAILS_LOG_TO_STDOUT' => '1',
          'RAILS_SERVE_STATIC_FILES' => '1',
          'WEB_PRELOAD_APP' => '1',
          'WEB_HEALTHCHECK_PATH' => '/healthcheck',
          'WEB_PORT' => 8080,
          'DATABASE_URL' => database_url
        }.merge(inherited_environment.to_h { |key| [key, nil] }).merge(rabbitmq_urls)
      end

      def rabbitmq_urls
        return {} unless Services::RabbitMQ::Configuration.new(Environment.new).enabled?

        { 'RABBITMQ_URL' => 'amqp://rabbitmq:5672', 'RABBITMQ_MANAGEMENT_URL' => 'http://rabbitmq:15672' }
      end

      def database_url
        {
          'postgresql' => 'postgresql://postgres:password@database-local:5432/production',
          'mysql2' => 'mysql2://root:password@database-local:3306/production',
          'sqlite3' => 'sqlite3:db/production.sqlite3'
        }.fetch(DockerCompose::ComposeConfiguration.database_adapter_name, nil)
      end

      def inherited_environment
        %w[HOST_UID RAILS_ENV SECRET_KEY_BASE WEB_CONCURRENCY WEB_TIMEOUT WEB_WORKER_PROCESSES]
      end

      def ports
        ['${PUBLISH_PORT:?PUBLISH_PORT must be provided}:8080']
      end
    end
  end
end
