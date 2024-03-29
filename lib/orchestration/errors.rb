# frozen_string_literal: true

module Orchestration
  class OrchestrationError < StandardError; end

  class HTTPConnectionError < OrchestrationError; end

  class DatabaseConfigurationError < OrchestrationError; end

  class MongoConfigurationError < OrchestrationError; end

  class UnknownEnvironmentError < DatabaseConfigurationError; end
end
