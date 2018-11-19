# frozen_string_literal: true

require 'thor'
require 'tempfile'

module HomeflowOrchestration
  class InstallGenerator < Thor::Group
    include Thor::Actions
    include FileHelpers

    def self.source_root
      HomeflowOrchestration.root.join(
        'lib', 'homeflow_orchestration', 'templates'
      )
    end

    def makefile
      environment = {
        app_id: Rails.application.class.parent.name.underscore,
        wait_commands: wait_commands
      }
      content = template_content('Makefile', environment)
      path = Rails.root.join('Makefile')
      delete_and_inject_after(path, "\n#!!homeflow_orchestration\n", content)
    end

    def dockerfile
      docker_dir = Rails.root.join('docker')
      path = docker_dir.join('Dockerfile')
      return if File.exist?(path)

      content = template_content('Dockerfile', ruby_version: RUBY_VERSION)
      FileUtils.mkdir(docker_dir) unless Dir.exist?(docker_dir)
      write_file(path, content)
    end

    def gitignore
      path = Rails.root.join('.gitignore')
      entries = [
        'docker/.build',
        'docker/Gemfile',
        'docker/Gemfile.lock',
        'docker/*.gemspec'
      ].map { |entry| "#{entry} # HomeflowOrchestration" }
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
      env = Environment.new(environment: 'test')
      {
        database: Services::Database::Configuration,
        mongo: Services::Mongo::Configuration,
        rabbitmq: Services::RabbitMQ::Configuration
      }.fetch(service).new(env)
    end

    def wait_commands
      [
        configuration(:database).settings.nil? ? nil : 'wait-database',
        configuration(:mongo).settings.nil? ? nil : 'wait-mongo',
        configuration(:rabbitmq).settings.nil? ? nil : 'wait-rabbitmq'
      ].compact.join(' ')
    end
  end
end
