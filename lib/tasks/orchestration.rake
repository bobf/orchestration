# frozen_string_literal: true

require 'orchestration'

namespace :orchestration do
  desc I18n.t('orchestration.rake.install')
  task :install do
    Orchestration::InstallGenerator.start
  end

  desc I18n.t('orchestration.makefile')
  task :makefile do
    Orchestration.makefile
  end

  desc I18n.t('orchestration.rake.config')
  task :config do
    config = YAML.safe_load(File.read('.orchestration.yml'))
    puts "#{config['docker']['organization']} #{config['docker']['repository']}"
  end

  namespace :db do
    desc I18n.t('orchestration.rake.db.url')
    task :url do
      config = Rails.application.config_for(:database)

      if config[:adapter] == 'sqlite3'
        puts "sqlite3:#{config[:database]}"
      else
        puts DatabaseUrl.to_active_record_url(config)
      end
    end

    desc I18n.t('orchestration.rake.db.console')
    task :console do
      env = Orchestration::Environment.new
      options = ENV['db'] ? { config_path: "config/database.#{ENV['db']}.yml" } : {}
      sh Orchestration::Services::Database::Configuration.new(env, nil, options).console_command
    end
  end

  desc I18n.t('orchestration.rake.compose_services')
  task :compose_services do
    config = Orchestration::DockerCompose::ComposeConfiguration.new(Orchestration::Environment.new)
    puts config.services.keys.join(' ') unless config.services.empty?
  end

  desc I18n.t('orchestration.rake.healthcheck')
  task :healthcheck do
    Orchestration::DockerHealthcheck.execute
  end

  desc I18n.t('orchestration.rake.wait')
  task :wait do
    env = Orchestration::Environment.new
    services = Orchestration::Services
    env.docker_compose_config['services'].each do |name, _service|
      path = nil

      adapter = if name == 'database'
                  services::Database
                elsif name.include?('database')
                  path = "config/database.#{name.sub('database-', '')}.yml"
                  services::Database
                elsif name == 'mongo'
                  services::Mongo
                elsif name == 'rabbitmq'
                  services::RabbitMQ
                else
                  services::Listener
                end

      adapter::Healthcheck.start(
        nil, nil, config_path: path, service_name: name, sidecar: ENV['sidecar']
      )
    end
  end
end
