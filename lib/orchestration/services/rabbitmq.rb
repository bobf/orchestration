# frozen_string_literal: true

module Orchestration
  module Services
    module RabbitMQ
      PORT = 5672
      MANAGER_PORT = 15_672
    end
  end
end

require 'orchestration/services/rabbitmq/configuration'
require 'orchestration/services/rabbitmq/healthcheck'
