# frozen_string_literal: true

module Orchestration
  module Kubernetes
    class Deployment
      def initialize(env)
        @env = env
      end

      def config
        {
          'apiVersion' => 'apps/v1',
          'kind' => 'Deployment',
          'metadata' => { 'name' => @env.app_name },
          'spec' => spec
        }
      end

      def spec
        {
          'replicas' => 3,
          'selector' => { 'matchLabels' => { 'app' => @env.app_name } },
          'template' => pod_template
        }
      end

      def pod_template
        {
          'metadata' => { 'labels' => { 'app' => @env.app_name } },
          'spec' => { 'containers' => [container] }
        }
      end

      def container
        {
          'name' => @env.app_name,
          'image' => "#{@env.organization}/#{@env.app_name}",
          'ports' => [{ 'containerPort' => 8080 }]
        }
      end
    end
  end
end
