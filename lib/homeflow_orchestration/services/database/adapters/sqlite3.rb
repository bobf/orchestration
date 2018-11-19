# frozen_string_literal: true

module HomeflowOrchestration
  module Services
    module Database
      module Adapters
        class Sqlite3
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
