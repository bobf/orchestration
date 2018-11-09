module Orchestration
  module Database
    class Configuration
      def initialize(path = 'config/database.yml')
        @environments = YAML.load_file(path)
      end

      def build
        # TODO: Mysql
        base_config.merge(
          'username' => 'postgres',
          'database' => 'postgres',
          'password' => ''
        )
      end

      def base_config
        host = url_config['host'] || @environments[rails_env]['host']

        @environments['default']
          .merge(url_config)
          .merge('host' => host)
      end

      private

      def rails_env
        ENV['RAILS_ENV'] || 'development'
      end

      def url_config
        return {} if ENV['DATABASE_URL'].nil?

        uri = URI.parse(ENV['DATABASE_URL'])

        {
          'host' => uri.hostname,
          'adapter' => uri.scheme,
          'port' => uri.port
        }.merge(query_params(uri))
      end

      def query_params(uri)
        return {} if uri.query.nil?

        Hash[URI.decode_www_form(uri.query)]
      end
    end
  end
end
