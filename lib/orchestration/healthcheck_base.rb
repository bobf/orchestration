# frozen_string_literal: true

module Orchestration
  module HealthcheckBase
    attr_reader :configuration

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def start(env = nil, terminal = nil, options = {})
        exit_on_error = options.fetch(:exit_on_error, true)
        options.delete(:exit_on_error)
        env ||= Environment.new
        terminal ||= Terminal.new
        check = ServiceCheck.new(new(env), terminal, options)

        exit 1 if !check.run && exit_on_error
      end
    end
  end
end
