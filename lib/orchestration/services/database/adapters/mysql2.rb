# frozen_string_literal: true

module Orchestration
  module Services
    module Database
      module Adapters
        class Mysql2
          def name
            'mysql2'
          end

          def image
            'library/mysql'
          end

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

          def environment
            {
              'MYSQL_ROOT_PASSWORD' => 'password',
              'MYSQL_TCP_PORT' => DockerCompose::DatabaseService::PORT.to_s
            }
          end

          def data_dir
            '/var/lib/mysql'
          end
        end
      end
    end
  end
end
