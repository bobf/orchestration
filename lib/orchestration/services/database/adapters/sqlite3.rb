# frozen_string_literal: true

module Orchestration
  module Services
    module Database
      module Adapters
        class Sqlite3
          include AdapterBase

          def name
            'sqlite3'
          end

          def credentials
            {
              'username' => '',
              'password' => '',
              'database' => 'healthcheck'
            }
          end

          def errors
            []
          end
        end
      end
    end
  end
end
