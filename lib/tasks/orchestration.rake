# frozen_string_literal: true

require 'orchestration'

namespace :orchestration do
  desc 'Initialise boilerplate for adding Docker to your application'
  task :install do
    Orchestration::InstallGenerator.start
  end

  namespace :application do
    desc 'Wait for application to become available'
    task :wait do
      Orchestration::Services::Application::Healthcheck.start
    end
  end

  namespace :database do
    desc 'Wait for database to become available'
    task :wait do
      Orchestration::Services::Database::Healthcheck.start
    end
  end

  namespace :mongo do
    desc 'Wait for mongo to become available'
    task :wait do
      Orchestration::Services::Mongo::Healthcheck.start
    end
  end

  namespace :nginx_proxy do
    desc 'Wait for Nginx proxy to become available'
    task :wait do
      Orchestration::Services::NginxProxy::Healthcheck.start
    end
  end

  namespace :rabbitmq do
    desc 'Wait for database to become available'
    task :wait do
      Orchestration::Services::RabbitMQ::Healthcheck.start
    end
  end

  namespace :docker do
    desc 'Output configured Docker username'
    task :username do
      STDOUT.write(
        Orchestration::Environment.new.settings.get('docker.username')
      )
      STDOUT.flush
    end
  end
end
