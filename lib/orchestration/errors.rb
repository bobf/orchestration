# frozen_string_literal: true

module Orchestration
  class OrchestrationError < StandardError; end
  class DatabaseConfigurationError < OrchestrationError; end
  class MongoConfigurationError < OrchestrationError; end
end
