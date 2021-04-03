# frozen_string_literal: true

module Orchestration
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/orchestration.rake'
      load 'tasks/kubernetes.rake'
    end
  end
end
