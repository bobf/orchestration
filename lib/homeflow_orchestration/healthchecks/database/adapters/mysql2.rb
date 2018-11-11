# frozen_string_literal: true

module Orchestration
  module Healthchecks
    module Database
      module Adapters
        class Mysql2
          def credentials
            {
              'username' => 'root',
              'password' => 'password',
              'database' => 'mysql'
            }
          end

          def errors
            [::Mysql2::Error]
          end
        end
      end
    end
  end
end
