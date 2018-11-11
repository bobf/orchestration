# frozen_string_literal: true

module Orchestration
  class OrchestrationError < StandardError; end
  class DatabaseConfigurationError < OrchestrationError; end
end
