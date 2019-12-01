# frozen_string_literal: true

require 'thor'
require 'tempfile'

module Orchestration
  class InstallGenerator < Thor::Group
    include FileHelpers

    def initialize(*_args)
      super
      @env = Environment.new(environment: 'test')
      @terminal ||= Terminal.new
    end

    def orchestration_configuration
      path = @env.orchestration_configuration_path
      settings = Settings.new(path)
      docker_username(settings)
      relpath = relative_path(path)
      return @terminal.write(:create, relpath) unless settings.exist?
      return @terminal.write(:update, relpath) if settings.dirty?

      @terminal.write(:skip, relpath)
    end

    def makefile
      environment = {
        app_id: @env.application_name,
        wait_commands: wait_commands
      }
      content = template('Makefile', environment)
      path = @env.root.join('Makefile')
      delete_and_inject_after(path, "\n#!!orchestration\n", content)
    end

    def dockerfile
      docker_dir = Rails.root.join('docker')
      path = docker_dir.join('Dockerfile')
      content = template('Dockerfile', ruby_version: RUBY_VERSION)
      FileUtils.mkdir(docker_dir) unless Dir.exist?(docker_dir)
      write_file(path, content, overwrite: false)
    end

    def gitignore
      path = Rails.root.join('.gitignore')
      entries = [
        'docker/.build',
        'docker/Gemfile',
        'docker/Gemfile.lock',
        'docker/*.gemspec'
      ].map { |entry| "#{entry} # Orchestration" }
      ensure_lines_in_file(path, entries)
    end

    def docker_compose
      path = Rails.root.join('docker-compose.yml')
      return if File.exist?(path)

      docker_compose = DockerCompose::Services.new(
        database: configuration(:database),
        mongo: configuration(:mongo),
        rabbitmq: configuration(:rabbitmq)
      )
      write_file(path, docker_compose.structure.to_yaml)
    end

    private

    def configuration(service)
      # REVIEW: At the moment we only handle test dependencies - it would be
      # nice to also handle development dependencies.
      {
        database: Services::Database::Configuration,
        mongo: Services::Mongo::Configuration,
        rabbitmq: Services::RabbitMQ::Configuration
      }.fetch(service).new(@env)
    end

    def wait_commands
      [
        configuration(:database).settings.nil? ? nil : 'wait-database',
        configuration(:mongo).settings.nil? ? nil : 'wait-mongo',
        configuration(:rabbitmq).settings.nil? ? nil : 'wait-rabbitmq'
      ].compact.join(' ')
    end

    def docker_username(settings)
      return unless settings.get('docker.username').nil?

      @terminal.write(:setup, I18n.t('orchestration.docker.username_request'))
      settings.set('docker.username', @terminal.read('[username]:'))
    end
  end
end
