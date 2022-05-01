require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
    config.load_defaults 7.0
    config.active_record.dump_schema_after_migration = false
  end
end

