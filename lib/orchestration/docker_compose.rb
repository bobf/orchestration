# frozen_string_literal: true

module Orchestration
  module DockerCompose
  end
end

require 'orchestration/docker_compose/services'
require 'orchestration/docker_compose/database_service'
require 'orchestration/docker_compose/mongo_service'
require 'orchestration/docker_compose/rabbitmq_service'
