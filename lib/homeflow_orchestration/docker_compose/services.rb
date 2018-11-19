# frozen_string_literal: true

module HomeflowOrchestration
  module DockerCompose
    class Services
      def initialize(options = {})
        @configurations = {
          'database' => options.fetch(:database, nil),
          'mongo' => options.fetch(:mongo, nil),
          'rabbitmq' => options.fetch(:rabbitmq, nil)
        }
      end

      def structure
        { 'version' => '3.7', 'services' => services }
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
          { name: 'database', class: DatabaseService },
          { name: 'mongo', class: MongoService },
          { name: 'rabbitmq', class: RabbitMQService }
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
