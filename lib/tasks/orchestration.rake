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

  desc I18n.t('orchestration.rake.config')
  task :config do
    config = YAML.safe_load(File.read('.orchestration.yml'))
    puts "#{config['docker']['organization']} #{config['docker']['repository']}"
  end

  desc I18n.t('orchestration.rake.healthcheck')
  task :healthcheck do
    Orchestration::DockerHealthcheck.execute
  end

  desc I18n.t('orchestration.rake.wait')
  task :wait do
    Orchestration::InstallGenerator.new.verify_makefile(skip: false)
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
