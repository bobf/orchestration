# frozen_string_literal: true

require 'bundler/setup'

require 'active_record'
require 'bunny'
require 'mongoid'
require 'mysql2'
require 'pg'
require 'sqlite3'
require 'webmock/rspec'

require 'orchestration'
require File.join(__dir__, 'dummy/config/environment.rb')

ENV['RACK_ENV'] = 'test'

Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |path| require path }

WebMock.disable_net_connect!(allow_localhost: false)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.include FixtureHelper

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
