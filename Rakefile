# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task' unless ENV.key?('ORCHESTRATION_TOOLKIT_ONLY')

RSpec::Core::RakeTask.new(:spec) if defined?(RSpec)

task default: :spec
