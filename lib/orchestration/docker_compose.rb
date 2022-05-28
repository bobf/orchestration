# frozen_string_literal: true

module Orchestration
  module DockerCompose
  end
end

require 'orchestration/docker_compose/compose_helpers'
require 'orchestration/docker_compose/install_generator'
require 'orchestration/docker_compose/configuration'
require 'orchestration/docker_compose/compose_configuration'

require 'orchestration/docker_compose/app_service'
require 'orchestration/docker_compose/database_service'
require 'orchestration/docker_compose/mongo_service'
require 'orchestration/docker_compose/rabbitmq_service'
require 'orchestration/docker_compose/redis_service'
