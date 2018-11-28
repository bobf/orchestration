# frozen_string_literal: true

module Orchestration
  class Environment
    def initialize(options = {})
      @environment = options.fetch(:environment, nil)
    end

    def environment
      return @environment unless @environment.nil?

      ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
    end

    def database_url
      ENV['DATABASE_URL']
    end

    def mongoid_configuration_path
      root.join('config', 'mongoid.yml')
    end

    def database_configuration_path
      root.join('config', 'database.yml')
    end

    def rabbitmq_configuration_path
      root.join('config', 'rabbitmq.yml')
    end

    def orchestration_configuration_path
      root.join('.orchestration.yml')
    end

    def application_name
      Rails.application.class.parent.name.underscore
    end

    def settings
      Settings.new(orchestration_configuration_path)
    end

    def root
      Rails.root
    end
  end
end
