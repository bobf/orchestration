# frozen_string_literal: true

module Orchestration
  module Healthchecks
    ATTEMPT_LIMIT = 10
    RETRY_INTERVAL = 3 # seconds
  end
end

require 'orchestration_orchestration/healthchecks/database'
