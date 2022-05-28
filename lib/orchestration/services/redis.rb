# frozen_string_literal: true

module Orchestration
  module Services
    module Redis
      PORT = 6379
    end
  end
end

require 'orchestration/services/redis/configuration'
require 'orchestration/services/redis/healthcheck'
