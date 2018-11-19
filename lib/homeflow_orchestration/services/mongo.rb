# frozen_string_literal: true

module HomeflowOrchestration
  module Services
    module Mongo
      PORT = 27_017
    end
  end
end

require 'homeflow_orchestration/services/mongo/configuration'
require 'homeflow_orchestration/services/mongo/healthcheck'
