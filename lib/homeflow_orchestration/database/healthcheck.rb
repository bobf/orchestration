# frozen_string_literal: true

require 'active_record'
require 'uri'

module Orchestration
  module Database
    class Healthcheck
      def initialize
        @configuration = Configuration.new
      end

      def start
        ActiveRecord::Base.establish_connection(@configuration.build)
        ActiveRecord::Base.connection
      end
    end
  end
end
