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
          },
          'command' => command,
          'entrypoint' => entrypoint,
          'healthcheck' => {
            'test' => healthcheck_command,
            'interval' => '30s',
            'timeout' => '15s',
            'start_period' => '15s',
            'retries' => 3
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

      def command
        %w(bundle exec) + case @config.env.web_server
                          when 'puma'
                            %w(puma -C config/puma.rb)
                          when 'unicorn'
                            %w(unicorn -c config/unicorn.rb)
                          else
                            unsupported_web_server
                          end
      end

      def entrypoint
        "/app/#{@config.env.orchestration_dir_name}/entrypoint.sh"
      end

      def healthcheck_command
        %w(CMD ruby) + ["/app/#{@config.env.orchestration_dir_name}/healthcheck.rb"]
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

      def unsupported_web_server
        raise ArgumentError,
              I18n.t(
                'orchestration.rake.app.unspported_web_server',
                server: @config.env.web_server,
                expected: %w(puma unicorn)
              )
      end
    end
  end
end
