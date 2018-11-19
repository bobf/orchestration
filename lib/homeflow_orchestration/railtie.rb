# frozen_string_literal: true

module HomeflowOrchestration
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/orchestration.rake'
    end
  end
end
