# frozen_string_literal: true

module Orchestration
  module Services
    module Mongo
      PORT = 27_017
    end
  end
end

require 'orchestration_orchestration/services/mongo/configuration'
require 'orchestration_orchestration/services/mongo/healthcheck'
