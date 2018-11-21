# frozen_string_literal: true

require 'colorize'
require 'i18n'
require 'rails'

I18n.load_path += Dir[File.join(File.expand_path('..', __dir__),
                                'config', 'locales', '**', '*.yml')]

require 'orchestration/docker_compose'
require 'orchestration/environment'
require 'orchestration/errors'
require 'orchestration/file_helpers'
require 'orchestration/healthcheck_base'
require 'orchestration/install_generator'
require 'orchestration/railtie'
require 'orchestration/service_check'
require 'orchestration/services'
require 'orchestration/terminal'
require 'orchestration/version'

module Orchestration
  def self.root
    Pathname.new(File.dirname(__dir__))
  end
end
