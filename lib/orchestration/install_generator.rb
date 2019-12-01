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
      @terminal.ask_setting('docker.organization')
      @terminal.ask_setting('docker.repository', @env.default_app_name)
      relpath = relative_path(path)
      return @terminal.write(:create, relpath) unless @settings.exist? || force?
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
      content = template(
        'Dockerfile',
        ruby_version: RUBY_VERSION,
        command: DockerCompose::AppService.command,
        entrypoint: DockerCompose::AppService.entrypoint,
        healthcheck: DockerCompose::AppService.healthcheck
      )
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

    def docker_compose
      @docker_compose.docker_compose_yml
      @docker_compose.docker_compose_test_yml
      @docker_compose.docker_compose_development_yml
      @docker_compose.docker_compose_local_yml
      @docker_compose.docker_compose_production_yml
      @docker_compose.docker_compose_override_yml
    end

    def puma
      return nil unless @env.web_server == 'puma'

      content = template('puma.rb')
      path = @env.root.join('config', 'puma.rb')
      create_file(path, content, overwrite: false)
    end

    def unicorn
      return nil unless @env.web_server == 'unicorn'

      content = template('unicorn.rb')
      path = @env.root.join('config', 'unicorn.rb')
      create_file(path, content, overwrite: false)
    end

    def database_yml
      return unless defined?(ActiveRecord)

      service_config('database.yml', Services::Database::Configuration)
    end

    def mongoid_yml
      return unless defined?(Mongoid)

      service_config('mongoid.yml', Services::Mongo::Configuration)
    end

    def rabbitmq_yml
      return unless defined?(Bunny)

      service_config('rabbitmq.yml', Services::RabbitMQ::Configuration)
    end

    def healthcheck
      simple_copy('healthcheck.rb')
    end

    def yaml_bash
      simple_copy('yaml.bash')
    end

    def env
      simple_copy('env', @env.root.join('.env'), overwrite: false)
    end

    def deploy_mk
      simple_copy('deploy.mk')
    end

    private

    def t(key)
      I18n.t("orchestration.#{key}")
    end

    def makefile_environment
      macros = template('makefile_macros.mk', env: @env)

      { env: @env, services: enabled_services, macros: macros }
    end

    def enabled_services
      %i[test development production].map do |environment|
        @docker_compose.enabled_services(environment)
      end.flatten.uniq
    end

    def service_config(filename, config_class)
      content = template(
        filename,
        config: config_class.new(@env),
        compose: proc do |env|
          DockerCompose::ComposeConfiguration.new(
            Environment.new(environment: env)
          )
        end
      )

      path = @env.root.join('config', filename)
      if path.exist?
        update_file(path, content, backup: true)
      else
        create_file(path, content)
      end
    end
  end
end
