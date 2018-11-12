# frozen_string_literal: true

require 'colorize'
require 'i18n'
require 'rails'

I18n.load_path += Dir[File.join(File.expand_path('..', __dir__),
                                'config', 'locales', '**', '*.yml')]

require 'orchestration_orchestration/docker_compose'
require 'orchestration_orchestration/errors'
require 'orchestration_orchestration/file_helpers'
require 'orchestration_orchestration/install_generator'
require 'orchestration_orchestration/railtie'
require 'orchestration_orchestration/services'
require 'orchestration_orchestration/terminal'
require 'orchestration_orchestration/version'

module Orchestration
  def self.root
    Pathname.new(File.dirname(__dir__))
  end
end
