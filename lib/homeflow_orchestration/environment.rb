# frozen_string_literal: true

module Orchestration
  class Environment
    def environment
      ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
    end

    def database_url
      ENV['DATABASE_URL']
    end

    def mongoid_configuration_path
      Rails.root.join('config', 'mongoid.yml')
    end

    def database_configuration_path
      Rails.root.join('config', 'database.yml')
    end
  end
end
