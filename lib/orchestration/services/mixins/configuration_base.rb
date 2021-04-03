# frozen_string_literal: true

module Orchestration
  module Services
    module ConfigurationBase
      attr_reader :service_name, :env, :error

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

      def initialize(env, service_name = nil, options = {})
        @env = env
        @options = options
        @service_name = service_name || self.class.service_name
      end

      def host
        return @service_name if @env.environment == 'test' && @options[:sidecar]
        return '127.0.0.1' if %w[test development].include?(@env.environment)

        @service_name
      end

      def configured?
        port
        true
      rescue KeyError => e
        @error = e
        false
      end

      def image
        service['image']
      end

      def port
        return @env.app_port if @service_name == 'app'

        local, remote = parse_port(service).map(&:to_i)
        return remote if @env.environment == 'test' && @options[:sidecar]

        (@env.environment == 'deployment' ? remote : local)
      end

      def service
        @service ||= @env.docker_compose_config
                         .fetch('services')
                         .fetch(@service_name)
      end

      def parse_port(service)
        # Remove our sidecar variable for easier parsing
        # '{sidecar-27018:}27017' => '27018:27017'
        local, _, remote = service.fetch('ports')
                                  .first
                                  .sub(/\${sidecar-(\d+):}/, '\1:')
                                  .partition(':')
        [local, remote]
      end

      def yaml(content)
        # Whitelist `Symbol` and permit aliases:
        YAML.safe_load(content, [Symbol], [], true)
      end
    end
  end
end
