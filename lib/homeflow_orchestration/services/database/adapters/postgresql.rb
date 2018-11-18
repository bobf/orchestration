# frozen_string_literal: true

module Orchestration
  module Services
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

          def default_port
            5432
          end
        end
      end
    end
  end
end
