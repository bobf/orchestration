# frozen_string_literal: true

module Orchestration
  module DockerCompose
    class AppService
      def initialize(config, environment)
        @environment = environment
        @config = config
      end

      class << self
        def command
          server = env.web_server
          %w(bundle exec) + case env.web_server
                            when 'puma'
                              %w(puma -C config/puma.rb)
                            when 'unicorn'
                              %w(unicorn -c config/unicorn.rb)
                            else
                              unsupported_web_server(server)
                            end
        end

        def entrypoint
          ["/app/#{orchestration}/entrypoint.sh"]
        end

        def healthcheck
          {
            'test' => %w(CMD ruby) + ["/app/#{orchestration}/healthcheck.rb"],
            # Defaults according to
            # https://docs.docker.com/engine/reference/builder/#healthcheck
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
          @environment ||= Environment.new
        end

        def unsupported_web_server(server)
          raise ArgumentError,
                I18n.t(
                  'orchestration.rake.app.unspported_web_server',
                  server: server,
                  expected: %w(puma unicorn)
                )
        end
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
        ['${CONTAINER_PORT}:8080']
      end
    end
  end
end
