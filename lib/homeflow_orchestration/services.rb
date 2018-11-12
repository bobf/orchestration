# frozen_string_literal: true

module Orchestration
  module Services
    ATTEMPT_LIMIT = 10
    RETRY_INTERVAL = 3 # seconds
  end
end

require 'orchestration_orchestration/services/database'
