# frozen_string_literal: true

require 'bundler/setup'
require 'orchestration_orchestration'
require File.join(__dir__, 'dummy/config/environment.rb')

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

Dir[__dir__ + '/support/**/*.rb'].each { |f| require f }
