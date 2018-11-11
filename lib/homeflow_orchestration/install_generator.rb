# frozen_string_literal: true

require 'thor'
require 'tempfile'

module Orchestration
  class InstallGenerator < Thor::Group
    include Thor::Actions
    include FileHelpers

    def self.source_root
      Orchestration.root.join(
        'lib', 'orchestration_orchestration', 'templates'
      )
    end

    def makefile
      environment = { app_id: Rails.application.class.parent.name.underscore }
      content = template_content('Makefile', environment)
      path = Rails.root.join('Makefile')
      delete_and_inject_after(path, "\n#!!orchestration_orchestration\n", content)
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
      line = 'docker/.build'
      ensure_line_in_file(path, line)
    end

    def docker_compose
      path = Rails.root.join('docker-compose.yml')
      return if File.exist?(path)

      docker_compose = DockerCompose.new(
        database: Healthchecks::Database::Configuration.new
      )
      write_file(path, docker_compose.structure.to_yaml)
    end
  end
end
