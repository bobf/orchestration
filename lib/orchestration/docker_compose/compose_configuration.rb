module Orchestration
  module DockerCompose
    class ComposeConfiguration
      def initialize(env)
        @env = env
      end

      def local_port(name, remote_port = nil)
        return nil if ports(name).empty?
        return ports(name).first[:local] if remote_port.nil?

        ports(name).find { |mapping| mapping[:remote] == remote_port }
                   .fetch(:local)
      end

      def services
        config['services']
      end

      private

      def config
        @config ||= @env.docker_compose_config
      end

      def ports(name)
        # TODO: Support both string and target/published hash formats
        services
          .fetch(name.to_s)
          .fetch('ports', [])
          .map do |pair|
            local, _, remote = pair.partition(':')
            { local: local, remote: remote }
          end
      end
    end
  end
end
