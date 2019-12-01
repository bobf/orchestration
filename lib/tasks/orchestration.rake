# frozen_string_literal: true

require 'orchestration'

namespace :orchestration do
  desc I18n.t('orchestration.rake.install')
  task :install do
    Orchestration::InstallGenerator.start
  end

  namespace :application do
    desc I18n.t('orchestration.application.wait')
    task :wait do
      Orchestration::Services::Application::Healthcheck.start
    end
  end

  namespace :database do
    desc I18n.t('orchestration.database.wait')
    task :wait do
      Orchestration::Services::Database::Healthcheck.start
    end
  end

  namespace :mongo do
    desc I18n.t('orchestration.mongo.wait')
    task :wait do
      Orchestration::Services::Mongo::Healthcheck.start
    end
  end

  namespace :nginx_proxy do
    desc I18n.t('orchestration.nginx-proxy.wait')
    task :wait do
      Orchestration::Services::NginxProxy::Healthcheck.start
    end
  end

  namespace :rabbitmq do
    desc I18n.t('orchestration.rabbitmq.wait')
    task :wait do
      Orchestration::Services::RabbitMQ::Healthcheck.start
    end
  end

  namespace :docker do
    desc I18n.t('orchestration.rake.docker.username')
    task :username do
      STDOUT.write(
        Orchestration::Environment.new.settings.get('docker.username')
      )
      STDOUT.flush
    end
  end

  namespace :listener do
    desc I18n.t('orchestration.rake.listener.wait')
    task :wait do
      Orchestration::Services::Listener::Healthcheck.start(
        nil, nil, service_name: ENV.fetch('service')
      )
    end
  end
end
