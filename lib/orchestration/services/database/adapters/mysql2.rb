# frozen_string_literal: true

module Orchestration
  module Services
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

          def default_port
            3306
          end
        end
      end
    end
  end
end
