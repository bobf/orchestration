# frozen_string_literal: true

module Orchestration
  module DockerCompose
    module ComposeHelpers
      def sidecar_port
        port = Orchestration.random_local_port
        # If env var `sidecar` is not set then output will be e.g.:
        # "50123:3306"
        # otherwise it will be:
        # "3306" (docker will use an ephemeral host port which we will not use)
        "${#{port}\:-sidecar}"
      end
    end
  end
end
