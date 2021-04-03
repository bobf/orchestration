# frozen_string_literal: true

module Orchestration
  module Kubernetes
    class Service
      def initialize(env)
        @env = env
      end

      def config
        {
          'apiVersion' => 'v1',
          'kind' => 'Service',
          'metadata' => { 'name' => @env.app_name, 'labels' => { 'run' => @env.app_name } },
          'spec' => spec
        }
      end

      def spec
        {
          'type' => 'LoadBalancer',
          'selector' => { 'run' => @env.app_name },
          'ports' => [{ 'port' => 8080, 'targetPort' => 8080, 'protocol' => 'TCP', 'name' => 'http' }]
        }
      end
    end
  end
end
