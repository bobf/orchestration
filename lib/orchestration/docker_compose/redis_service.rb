# frozen_string_literal: true

module Orchestration
  module DockerCompose
    class RedisService
      include ComposeHelpers

      def initialize(config, environment)
        @config = config
        @environment = environment
      end

      def definition
        return nil unless @config.enabled?

        { 'image' => 'library/redis:7.0', 'networks' => networks }.merge(ports)
      end

      def ports
        return {} unless %i[development test].include?(@environment)

        container_port = Orchestration::Services::Redis::PORT

        { 'ports' => ["#{sidecar_port(@environment)}#{container_port}"] }
      end
    end
  end
end
