# frozen_string_literal: true

module Orchestration
  module Kubernetes
    class Environment
      def initialize(env_file:, env: Orchestration::Environment.new)
        @env = env
        @env_file = env_file
      end

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

      def spec
        { 'template' => { 'spec' => { 'containers' => [container] } } }
      end

      def container
        { 'name' => @env.app_name, 'env' => environment }
      end

      def environment
        return [] if @env_file.nil?

        File.readlines(@env_file).map do |line|
          stripped = line.strip
          next nil if stripped.blank? || stripped[0] == '#'

          name, _, value = stripped.partition('=')
          { 'name' => name, 'value' => value }
        end.compact
      end
    end
  end
end
