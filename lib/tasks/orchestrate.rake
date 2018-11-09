require 'orchestration_orchestration'

namespace 'orchestration' do
  desc 'Initialise boilerplate for adding Docker to your application'
  task :orchestrate do
    Orchestration::InstallGenerator.start
  end

  namespace :orchestrate do
    namespace :db do
      desc 'Wait for database to become available'
      task :wait do
        Orchestration::Database::Healthcheck.new.start
      end
    end
  end
end
