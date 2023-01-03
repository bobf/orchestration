# frozen_string_literal: true

ENV['ORCHESTRATION_DISABLE_ENV'] = '1'

require 'orchestration'
puts Orchestration.makefile
