# frozen_string_literal: true

module Orchestration
  module DockerCompose
    class Services
      def initialize(env, options = {})
        @env = env
        @configurations = {
          'application' => options.fetch(:application, nil),
          'database' => options.fetch(:database, nil),
          'mongo' => options.fetch(:mongo, nil),
          'rabbitmq' => options.fetch(:rabbitmq, nil),
          'nginx-proxy' => options.fetch(:nginx_proxy, nil)
        }
      end

      def structure
        {
          'version' => '3.7',
          'services' => services,
          'volumes' => {
            @env.public_volume => nil
          }
        }
      end

      def services
        Hash[filtered_services]
      end

      private

      def filtered_services
        services_enabled.compact.reject { |_name, definition| definition.nil? }
      end

      def services_available
        [
          { name: 'application', class: ApplicationService },
          { name: 'database', class: DatabaseService },
          { name: 'mongo', class: MongoService },
          { name: 'rabbitmq', class: RabbitMQService },
          { name: 'nginx-proxy', class: NginxProxyService }
        ]
      end

      def services_enabled
        services_available.map do |service|
          config = @configurations[service[:name]]
          # REVIEW: This is mostly here for testing - we may not need it once
          # everything's implemented.
          next if config.nil?

          [service[:name], service[:class].new(config).definition]
        end
      end
    end
  end
end
