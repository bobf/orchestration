# frozen_string_literal: true

module Orchestration
  class DockerCompose
    def initialize(options = {})
      @database = options.fetch(:database, nil)
    end

    def structure
      { 'version' => '3.7', 'services' => services }
    end

    def services
      Hash[filtered_services]
    end

    private

    def defined_services
      [
        { service: 'database', definition: database_service }
      ]
    end

    def filtered_services
      defined_services.map do |service|
        next if service[:definition].nil?

        [service[:service], service[:definition]]
      end.compact
    end

    def database_service
      return nil if @database.nil?

      adapter = @database.settings['adapter']
      return nil if adapter == 'sqlite3'

      {
        'image' => image_from_adapter(adapter),
        'environment' => environment_from_adapter(adapter)
      }
    end

    def image_from_adapter(adapter)
      {
        'postgresql' => 'library/postgres',
        'mysql2' => 'library/mysql'
      }.fetch(adapter)
    end

    def environment_from_adapter(adapter)
      {
        'postgresql' => {
          'PGPORT' => 5499,
          'POSTGRES_PASSWORD' => 'password'
        },
        'mysql2' => {
          'MYSQL_ROOT_PASSWORD' => 'password',
          'MYSQL_TCP_PORT' => 3399
        }
      }.fetch(adapter)
    end
  end
end
