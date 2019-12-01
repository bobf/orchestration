# frozen_string_literal: true

module Orchestration
  module Services
    module App
      class Healthcheck
        include HealthcheckBase
        include HTTPHealthcheck
      end
    end
  end
end
