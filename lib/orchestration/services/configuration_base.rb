# frozen_string_literal: true

module Orchestration
  module Services
    module ConfigurationBase
      attr_reader :settings, :service_name

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
        '127.0.0.1'
      end

      def local_port
        key = @service_name == 'application' ? 'nginx-proxy' : @service_name

        @env.docker_compose_config
            .fetch('services')
            .fetch(key)
            .fetch('ports')
            .first
            .partition(':')
            .first
            .to_i
      end
    end
  end
end
