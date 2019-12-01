# frozen_string_literal: true

module Orchestration
  module DockerCompose
    class HAProxyService
      def initialize(config, environment)
        @environment = environment
        @config = config
      end

      def definition
        {
          'deploy' => {
            'placement' => { 'constraints' => ['node.role == manager'] }
          },
          'image' => 'dockercloud/haproxy',
          'ports' => %w[${LISTEN_PORT}:80],
          'volumes' => [
            '/var/run/docker.sock:/var/run/docker.sock:ro'
          ]
        }
      end
    end
  end
end
