# frozen_string_literal: true

require 'orchestration_orchestration/install_generator'
require 'orchestration_orchestration/railtie' if defined?(Rails)
require 'orchestration_orchestration/version'

module Orchestration
  def self.root
    Pathname.new(File.dirname(__dir__))
  end
end
