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
        Orchestration::Healthchecks::Database::Healthcheck.start
      end
    end
  end
end
