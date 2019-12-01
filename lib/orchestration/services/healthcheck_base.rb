# frozen_string_literal: true

module Orchestration
  module Services
    module HealthcheckBase
      attr_reader :configuration

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def start(env = nil, terminal = nil, options = {})
          load_dependencies
          exit_on_error = options.fetch(:exit_on_error, true)
          options.delete(:exit_on_error)
          env ||= Environment.new
          terminal ||= Terminal.new(env.settings)
          name = options.delete(:service_name)
          check = ServiceCheck.new(new(env, name, options), terminal, options)

          exit 1 if !check.run && exit_on_error
        end

        def dependencies(*args)
          @dependencies = args
        end

        private

        def load_dependencies
          return if @dependencies.nil?

          @dependencies.map { |dependency| require dependency }
        end
      end

      def initialize(env, service_name = nil, options = {})
        @options = options
        @configuration = configuration_class.new(env, service_name)
      end

      def service_name
        @configuration.service_name
      end

      private

      def configuration_class
        # Find the relevant `Configuration` class for whatever `Healthcheck`
        # class we happen to be included in.
        instance_eval(self.class.name.rpartition('::').first)
          .const_get(:Configuration)
      end

      def devnull
        File.open(File::NULL, 'w')
      end
    end
  end
end
