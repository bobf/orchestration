# frozen_string_literal: true

require 'colorize'
require 'i18n'
require 'rails'

I18n.load_path += Dir[File.join(File.expand_path('..', __dir__),
                                'config', 'locales', '**', '*.yml')]

require 'homeflow_orchestration/docker_compose'
require 'homeflow_orchestration/environment'
require 'homeflow_orchestration/errors'
require 'homeflow_orchestration/file_helpers'
require 'homeflow_orchestration/healthcheck_base'
require 'homeflow_orchestration/install_generator'
require 'homeflow_orchestration/railtie'
require 'homeflow_orchestration/service_check'
require 'homeflow_orchestration/services'
require 'homeflow_orchestration/terminal'
require 'homeflow_orchestration/version'

module HomeflowOrchestration
  def self.root
    Pathname.new(File.dirname(__dir__))
  end
end
