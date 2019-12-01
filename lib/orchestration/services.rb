# frozen_string_literal: true

module Orchestration
  module Services
  end
end

require 'orchestration/services/configuration_base'
require 'orchestration/services/healthcheck_base'

require 'orchestration/services/application'
require 'orchestration/services/database'
require 'orchestration/services/mongo'
require 'orchestration/services/nginx_proxy'
require 'orchestration/services/rabbitmq'
