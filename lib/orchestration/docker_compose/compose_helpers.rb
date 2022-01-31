# frozen_string_literal: true

module Orchestration
  module DockerCompose
    module ComposeHelpers
      def sidecar_port(environment)
        port = Orchestration.random_local_port
        return "#{port}:" unless environment == :test

        # If env var `sidecar` is not set then ports will be configured as e.g.:
        # "50123:3306"
        # otherwise it will be:
        # "3306" (docker will use an ephemeral host port which we will not use)
        "${sidecar-#{port}:}"
      end

      def networks
        service = self.class.name.rpartition('::').last.partition('Service').first.downcase
        network_alias = %i[development test].include?(@environment) ? service : "#{service}-local"
        { 'local' => { 'aliases' => [network_alias] } }
      end
    end
  end
end
