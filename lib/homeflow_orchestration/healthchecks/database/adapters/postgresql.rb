# frozen_string_literal: true

module Orchestration
  module Healthchecks
    module Database
      module Adapters
        class Postgresql
          def credentials
            {
              'username' => 'postgres',
              'password' => 'password',
              'database' => 'postgres'
            }
          end

          def errors
            [PG::ConnectionBad]
          end
        end
      end
    end
  end
end
