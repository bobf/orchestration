# frozen_string_literal: true

require 'orchestration_orchestration'

namespace 'orchestration' do
  namespace :orchestration do
    desc 'Initialise boilerplate for adding Docker to your application'
    task :install do
      Orchestration::InstallGenerator.start
    end

    namespace :db do
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

    namespace :rabbitmq do
      desc 'Wait for database to become available'
      task :wait do
        Orchestration::Services::RabbitMQ::Healthcheck.start
      end
    end
  end
end
