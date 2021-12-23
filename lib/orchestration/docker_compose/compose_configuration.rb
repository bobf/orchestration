# frozen_string_literal: true

module Orchestration
  module DockerCompose
    class ComposeConfiguration
      def self.database_adapter_name
        return nil unless defined?(ActiveRecord)
        return 'postgresql' if defined?(::PG)
        return 'mysql2' if defined?(::Mysql2)
        return 'sqlite3' if defined?(::SQLite3)

        nil
      end

      def initialize(env)
        @env = env
      end

      def services
        config['services']
      end

      def database_adapter_name
        self.class.database_adapter_name
      end

      def database_adapter
        return nil unless defined?(ActiveRecord)

        base = Orchestration::Services::Database::Adapters
        return base::Postgresql.new if defined?(::PG)
        return base::Mysql2.new if defined?(::Mysql2)
        return base::Sqlite3.new if defined?(::SQLite3)

        nil
      end

      def local_port(name, remote_port = nil)
        return nil unless listener?(name)
        return ports(name).first[:local].to_i if remote_port.nil?

        ports(name).find { |mapping| mapping[:remote] == remote_port }
                   .fetch(:local)
                   .to_i
      end

      private

      def config
        @config ||= @env.docker_compose_config
      rescue Errno::ENOENT
        {}
      end

      def listener?(name)
        services.key?(name.to_s) && !ports(name).empty?
      end

      def ports(name)
        services
          .fetch(name.to_s)
          .fetch('ports', [])
          .map do |mapping|
            next short_format_ports(mapping) if mapping.is_a?(String)

            {
              local: mapping.fetch('published'),
              remote: mapping.fetch('target')
            }
          end
      end

      def short_format_ports(mapping)
        # Remove our sidecar variable for easier parsing
        # '{sidecar-27018:}27017' => '27018:27017'
        local, _, remote = mapping.sub(/\${sidecar-(\d+):}/, '\1:')
                                  .partition(':')
        { local: local, remote: remote }
      end
    end
  end
end
