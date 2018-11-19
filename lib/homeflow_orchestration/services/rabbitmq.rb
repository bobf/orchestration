# frozen_string_literal: true

module HomeflowOrchestration
  module Services
    module RabbitMQ
      PORT = 5672
    end
  end
end

require 'homeflow_orchestration/services/rabbitmq/configuration'
require 'homeflow_orchestration/services/rabbitmq/healthcheck'
