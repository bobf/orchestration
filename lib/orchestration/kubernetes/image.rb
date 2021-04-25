# frozen_string_literal: true

module Orchestration
  module Kubernetes
    class Image
      include KustomizationPatch

      def initialize(image:, env: Orchestration::Environment.new)
        @env = env
        @image = image
      end

      private

      def spec
        { 'template' => { 'spec' => { 'containers' => [container] } } }
      end

      def container
        { 'name' => @env.app_name, 'image' => @image }
      end
    end
  end
end
