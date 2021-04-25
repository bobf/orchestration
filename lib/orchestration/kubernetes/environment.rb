# frozen_string_literal: true

module Orchestration
  module Kubernetes
    class Environment
      include KustomizationPatch

      def initialize(env_file:, env: Orchestration::Environment.new)
        @env = env
        @env_file = env_file
      end

      private

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
