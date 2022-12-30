# frozen_string_literal: true

require 'erb'
require 'pathname'
require 'socket'
require 'yaml'

require 'database_url'
require 'erubis'
require 'i18n'
require 'paint'
begin
  require 'rails'
rescue LoadError
  warn('[orchestration] Running in non-Rails mode.')
end

I18n.load_path += Dir[File.join(File.expand_path('..', __dir__),
                                'config', 'locales', '**', '*.yml')]

require 'orchestration/file_helpers'

require 'orchestration/docker_compose'
require 'orchestration/environment'
require 'orchestration/errors'
require 'orchestration/docker_healthcheck'
require 'orchestration/install_generator'
require 'orchestration/railtie' if defined?(Rails)
require 'orchestration/service_check'
require 'orchestration/services'
require 'orchestration/settings'
require 'orchestration/terminal'
require 'orchestration/version'

module Orchestration
  class << self
    def root
      Pathname.new(File.dirname(__dir__))
    end

    def makefile
      root.join('lib', 'orchestration', 'make', 'orchestration.mk')
    end

    def rakefile
      root.join('lib', 'Rakefile')
    end

    def error(key, options = {})
      warn('# Orchestration Error')
      warn("# #{I18n.t("orchestration.#{key}", options)}")
    end

    def random_local_port
      socket = Socket.new(:INET, :STREAM, 0)
      socket.bind(Addrinfo.tcp('127.0.0.1', 0))
      port = socket.local_address.ip_port
      socket.close
      port
    end

    def print_environment
      return unless File.exist?('.env')

      $stdout.puts
      $stdout.puts("#{prefix} #{Paint['Loading environment from', :cyan]} #{Paint['.env', :green]}")
      $stdout.puts
      environment_variables.each do |variable, value|
        terminal.print_variable(variable, value)
      end
      $stdout.puts
    end

    private

    def terminal
      @terminal ||= Terminal.new(Environment.new.settings)
    end

    def prefix
      "#{Paint['[', :white]}#{Paint['orchestration', :cyan]}#{Paint[']', :white]}"
    end

    def environment_variables
      File.readlines('.env').reject { |line| line.match(/^\s*#/) }
          .select { |line| line.include?('=') }
          .map do |line|
            variable, _, value = line.partition('=')
            [variable, value]
          end
    end
  end
end

if ENV['RAILS_ENV'] == 'development'
  require 'dotenv-rails'
  Dotenv::Railtie.load
  Orchestration.print_environment
end
