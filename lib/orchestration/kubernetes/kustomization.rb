# frozen_string_literal: true

module Orchestration
  module Kubernetes
    class Kustomization
      def initialize(env)
        @env = env
      end

      def config
        {
          'apiVersion' => 'kustomize.config.k8s.io/v1beta1',
          'kind' => 'Kustomization',
          'resources' => %w[deployment.yml service.yml],
          'patchesStrategicMerge' => %w[environmentPatch.yml imagePatch.yml]
        }
      end
    end
  end
end
