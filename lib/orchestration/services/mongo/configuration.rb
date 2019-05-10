# frozen_string_literal: true

module Orchestration
  module Services
    module Mongo
      class Configuration
        include ConfigurationBase

        self.service_name = 'mongo'

        def enabled?
          defined?(Mongoid)
        end

        def friendly_config
          "[mongoid] #{host}:#{port}/#{database}"
        end

        private

        def host
          return from_url['host'] if ENV.key?('MONGO_URL')

          '127.0.0.1'
        end

        def port
          return from_url['port'] if ENV.key?('MONGO_URL')

          DockerCompose::ComposeConfiguration.new(@env).local_port('mongo')
        end

        def from_url
          uri = URI.parse(ENV.fetch('MONGO_URL'))
          proto = uri.gsub(%r{([a-zA-Z0-9+-_]+)://.*$}, '\1')
          unless proto == 'mongodb'
            raise ArgumentError, 'MONGO_URL protocol must be mongodb://'
          end

          rest = uri[(proto + '://').size..-1]
          hosts_string, _, database = rest.rpartition('/')

          user = nil
          password = nil

          hosts = hosts_string.split(',').each do |string|
            uri = URI.parse("mongodb://#{string}")
            host ||= uri.host
            port ||= uri.port
            break unless host.nil? && port.nil?
          end

          { 'host' => host, 'port' => port || Services::Mongo::PORT }
        end
      end
    end
  end
end

  uri = ENV.fetch('MONGO_URL', 'mongodb://localhost:27017/bake')

  proto = uri.gsub(%r{([a-zA-Z0-9+-_]+)://.*$}, '\1')
  unless proto == 'mongodb'
    raise ArgumentError, 'MONGO_URL protocol must be mongodb://'
  end

  rest = uri[(proto + '://').size..-1]
  hosts_string, _, database = rest.rpartition('/')

  user = nil
  password = nil

  hosts = hosts_string.split(',').map do |string|
    uri = URI.parse("mongodb://#{string}")
    user ||= uri.user
    password ||= uri.password
    "#{uri.host}:#{uri.port.nil? ? 27017 : uri.port }"
  end
