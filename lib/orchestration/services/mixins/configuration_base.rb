# frozen_string_literal: true

module Orchestration
  module Services
    module ConfigurationBase
      attr_reader :service_name, :env

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def service_name=(val)
          @service_name = val
        end

        def service_name
          return @service_name unless @service_name.nil?

          raise ArgumentError,
                "Must call `self.name=` on #{self.class.service_name}"
        end
      end

      def initialize(env, service_name = nil)
        @env = env
        @service_name = service_name || self.class.service_name
      end

      def host
        return '127.0.0.1' if %w[test development].include?(@env.environment)

        @service_name
      end

      def port
        return @env.app_port if @service_name == 'app'

        local, _, remote = @env.docker_compose_config
                               .fetch('services')
                               .fetch(@service_name)
                               .fetch('ports')
                               .first
                               .partition(':')

        (@env.environment == 'production' ? remote : local).to_i
      end

      def yaml(content)
        # Whitelist `Symbol` and permit aliases:
        YAML.safe_load(content, [Symbol], [], true)
      end
    end
  end
end
