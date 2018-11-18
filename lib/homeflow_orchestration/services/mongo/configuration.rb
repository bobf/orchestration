# frozen_string_literal: true

module Orchestration
  module Services
    module Mongo
      class Configuration
        attr_reader :settings

        def initialize(env)
          @env = env
          @settings = nil
          return unless defined?(Mongoid)
          return unless File.exist?(@env.mongoid_configuration_path)

          @settings = config.fetch(@env.environment)
        end

        def ports
          hosts_and_ports.map { |_host, port| port }
        end

        def friendly_config
          hosts_string = hosts_and_ports.map do |host, port|
            "#{host}:#{port}"
          end.join(', ')

          "[mongoid] #{hosts_string}"
        end

        private

        def config
          YAML.safe_load(
            File.read(@env.mongoid_configuration_path), [], [], true
          )
        end

        def clients
          # 'sessions' and 'clients' are synonymous but vary between versions of
          # Mongoid: https://github.com/mongoid/mongoid/commit/657650bc4befa001c0f66e8788e9df6a1af37e84
          key = @settings.key?('sessions') ? 'sessions' : 'clients'

          @settings.fetch(key)
        end

        def hosts_and_ports
          clients.fetch('default').fetch('hosts').map do |host_string|
            host, _, port = host_string.partition(':')
            [host, (port.empty? ? PORT : port)]
          end
        end
      end
    end
  end
end
