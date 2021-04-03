# frozen_string_literal: true

module Orchestration
  module Kubernetes
    class InstallGenerator
      include FileHelpers

      def initialize(env, terminal)
        @env = env
        @terminal = terminal
      end

      def kubernetes
        write_config(:deployment)
        write_config(:service)
        write_config(:kustomization)
      end

      private

      def write_config(item)
        create_file(
          path.join("#{item}.yml"),
          "Orchestration::Kubernetes::#{item.capitalize}".constantize.new(@env).config.to_yaml,
          overwrite: false
        )
      end

      def path
        @env.kubernetes_configuration_path
      end
    end
  end
end
