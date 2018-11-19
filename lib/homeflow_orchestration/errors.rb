# frozen_string_literal: true

module HomeflowOrchestration
  class HomeflowOrchestrationError < StandardError; end
  class DatabaseConfigurationError < HomeflowOrchestrationError; end
  class MongoConfigurationError < HomeflowOrchestrationError; end
end
