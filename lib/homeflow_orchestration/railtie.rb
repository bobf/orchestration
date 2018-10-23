module Orchestration
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/orchestrate.rake'
    end
  end
end
