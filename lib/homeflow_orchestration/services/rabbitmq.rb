# frozen_string_literal: true

module Orchestration
  module Services
    module RabbitMQ
      PORT = 5672
    end
  end
end

require 'orchestration_orchestration/services/rabbitmq/configuration'
require 'orchestration_orchestration/services/rabbitmq/healthcheck'
