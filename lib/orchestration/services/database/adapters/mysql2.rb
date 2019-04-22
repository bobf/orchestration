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
            return mysql5_7 if gem_version < Gem::Version.new('0.4')

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
              'MYSQL_ROOT_PASSWORD' => 'password'
            }
          end

          def data_dir
            '/var/lib/mysql'
          end

          private

          def mysql5_7
            'library/mysql:5.7'
          end

          def gem_version
            Gem::Version.new(Gem.loaded_specs["mysql2"].version)
          end
        end
      end
    end
  end
end
