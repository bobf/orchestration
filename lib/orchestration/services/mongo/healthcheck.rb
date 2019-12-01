# frozen_string_literal: true

module Orchestration
  module Services
    module Mongo
      class Healthcheck
        include HealthcheckBase
        include HTTPHealthcheck

        def connection_success?(code)
          code == '200'
        end
      end
    end
  end
end
