# frozen_string_literal: true

module HomeflowOrchestration
  module HealthcheckBase
    attr_reader :configuration

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def start(env = nil, terminal = nil)
        env ||= Environment.new
        terminal ||= Terminal.new
        check = ServiceCheck.new(new(env), terminal)

        exit 1 unless check.run
      end
    end
  end
end
