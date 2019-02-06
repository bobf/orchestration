# frozen_string_literal: true

require 'thor'
require 'tempfile'

module Orchestration
  class InstallGenerator < Thor::Group
    include FileHelpers

    def initialize(*_args)
      super
      @env = Environment.new
      @settings = Settings.new(@env.orchestration_configuration_path)
      @terminal = Terminal.new(@settings)
      @docker_compose = DockerCompose::InstallGenerator.new(@env, @terminal)
    end

    def orchestration_configuration
      path = @env.orchestration_configuration_path
      @terminal.ask_setting('docker.registry')
      @terminal.ask_setting('docker.organization')
      @terminal.ask_setting('docker.repository', @env.default_app_name)
      relpath = relative_path(path)
      return @terminal.write(:create, relpath) unless @settings.exist?
      return @terminal.write(:update, relpath) if @settings.dirty?

      @terminal.write(:skip, relpath)
    end

    def orchestration_makefile
      content = template('orchestration.mk', makefile_environment)
      path = @env.orchestration_root.join('Makefile')
      path.exist? ? update_file(path, content) : create_file(path, content)
    end

    def application_makefile
      path = @env.root.join('Makefile')
      simple_copy('application.mk', path) unless File.exist?(path)
      inject_if_missing(path, 'include orchestration/Makefile')
    end

    def dockerfile
      content = template('Dockerfile', ruby_version: RUBY_VERSION)
      create_file(
        orchestration_dir.join('Dockerfile'),
        content,
        overwrite: false
      )
    end

    def entrypoint_sh
      content = template('entrypoint.sh')
      path = orchestration_dir.join('entrypoint.sh')
      create_file(path, content, overwrite: false)
      FileUtils.chmod('a+x', path)
    end

    def gitignore
      path = @env.root.join('.gitignore')
      globs = %w[.build/ .deploy/ Gemfile Gemfile.lock docker-compose.local.yml]
      entries = %w[.env deploy.tar] + globs.map do |entry|
        "#{@env.orchestration_dir_name}/#{entry}"
      end

      ensure_lines_in_file(path, entries)
    end

    def unicorn
      content = template('unicorn.rb')
      path = @env.root.join('config', 'unicorn.rb')
      create_file(path, content, overwrite: false)
    end

    def yaml_bash
      simple_copy('yaml.bash', @env.orchestration_root.join('yaml.bash'))
    end

    def env
      simple_copy('env', @env.root.join('.env'), overwrite: false)
    end

    def deploy_mk
      simple_copy('deploy.mk', @env.orchestration_root.join('deploy.mk'))
    end

    def docker_compose
      @docker_compose.docker_compose_yml
      @docker_compose.docker_compose_test_yml
      @docker_compose.docker_compose_development_yml
      @docker_compose.docker_compose_local_yml
      @docker_compose.docker_compose_production_yml
      @docker_compose.docker_compose_override_yml
    end

    private

    def t(key)
      I18n.t("orchestration.#{key}")
    end

    def makefile_environment
      { env: @env, wait_commands: wait_commands }
    end

    def wait_commands
      %i[test development production].map do |environment|
        @docker_compose.enabled_services(environment).map do |service|
          "wait-#{service}"
        end
      end.flatten.uniq
    end
  end
end
