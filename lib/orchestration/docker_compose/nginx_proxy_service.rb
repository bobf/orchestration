# frozen_string_literal: true

module Orchestration
  module DockerCompose
    class NginxProxyService
      def initialize(config)
        @config = config
      end

      def definition
        {
          'image' => 'jwilder/nginx-proxy',
          'ports' => %w[3000:80],
          'volumes' => ['/var/run/docker.sock:/tmp/docker.sock:ro']
        }
      end
    end
  end
end
