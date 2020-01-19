# frozen_string_literal: true

require 'orchestration'

namespace :orchestration do
  desc I18n.t('orchestration.rake.install')
  task :install do
    Orchestration::InstallGenerator.start
  end

  namespace :install do
    desc I18n.t('orchestration.rake.install_makefile')
    task :makefile do
      Orchestration::InstallGenerator.new.orchestration_makefile
    end
  end

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

  namespace :app do
    desc I18n.t('orchestration.rake.app.wait')
    task :wait do
      Orchestration::Services::App::Healthcheck.start(
        nil, nil, config_path: ENV['config'], service_name: ENV['service']
      )
    end
  end

  namespace :database do
    desc I18n.t('orchestration.rake.database.wait')
    task :wait do
      Orchestration::Services::Database::Healthcheck.start(
        nil, nil, config_path: ENV['config'], service_name: ENV['service']
      )
    end
  end

  namespace :mongo do
    desc I18n.t('orchestration.rake.mongo.wait')
    task :wait do
      Orchestration::Services::Mongo::Healthcheck.start(
        nil, nil, config_path: ENV['config'], service_name: ENV['service']
      )
    end
  end

  namespace :rabbitmq do
    desc I18n.t('orchestration.rake.rabbitmq.wait')
    task :wait do
      Orchestration::Services::RabbitMQ::Healthcheck.start(
        nil, nil, config_path: ENV['config'], service_name: ENV['service']
      )
    end
  end

  namespace :listener do
    desc I18n.t('orchestration.rake.listener.wait')
    task :wait do
      Orchestration::Services::Listener::Healthcheck.start(
        nil, nil, service_name: ENV.fetch('service'),
                  sidecar: ENV['sidecar']
      )
    end
  end
end
