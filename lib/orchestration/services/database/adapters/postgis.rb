# frozen_string_literal: true

module Orchestration
  module Services
    module Database
      module Adapters
        class Postgis
          include AdapterBase

          def name
            'postgis'
          end

          def image
            'postgis/postgis'
          end

          def credentials
            {
              'username' => 'postgres',
              'password' => 'password',
              'database' => 'postgis'
            }
          end

          def errors
            [PG::ConnectionBad]
          end

          def default_port
            5432
          end

          def environment
            {
              'POSTGRES_PASSWORD' => 'password',
              'PGDATA' => data_dir
            }
          end

          def data_dir
            '/var/pgdata'
          end
        end
      end
    end
  end
end
