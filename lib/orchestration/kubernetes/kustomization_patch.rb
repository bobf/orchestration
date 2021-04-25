# frozen_string_literal: true

module Orchestration
  module Kubernetes
    module KustomizationPatch
      def content
        structure.to_yaml
      end

      private

      def structure
        {
          'apiVersion' => 'apps/v1',
          'kind' => 'Deployment',
          'metadata' => { 'name' => @env.app_name },
          'spec' => spec
        }
      end
    end
  end
end
