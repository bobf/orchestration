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
        "${#{port}\:-sidecar}"
      end
    end
  end
end
