# frozen_string_literal: true

require 'thor'
require 'tempfile'

module Orchestration
  # rubocop:disable Metrics/ClassLength
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

    def verify_makefile(skip: true)
      # Only run when called explicitly [from Rake tasks].
      # (I know this is hacky).
      return if skip

      content = template('orchestration.mk', makefile_environment)
      path = @env.orchestration_root.join('Makefile')
      return if path.exist? && content == File.read(path)

      write_file(path, content)
      @terminal.write(:update, 'Makefile')
      @terminal.write(:status, t(:auto_update))
    end

    def application_makefile
      path = @env.root.join('Makefile')
      simple_copy('application.mk', path) unless File.exist?(path)
      inject_if_missing(path, 'include orchestration/Makefile')
    end

    def orchestration_makefile
      content = template('orchestration.mk', makefile_environment)
      path = @env.orchestration_root.join('Makefile')
      path.exist? ? update_file(path, content) : create_file(path, content)
    end

    def dockerfile
      create_file(
        orchestration_dir.join('Dockerfile'),
        dockerfile_content,
        overwrite: false
      )
    end

    def entrypoint_sh
      content = template('entrypoint.sh')
      path = orchestration_dir.join('entrypoint.sh')
      create_file(path, content, overwrite: false)
      FileUtils.chmod('a+x', path)
    end

    def docker_compose
      @docker_compose.docker_compose_test_yml
      @docker_compose.docker_compose_development_yml
      @docker_compose.docker_compose_production_yml
    end

    def puma
      return nil unless @env.web_server == 'puma'

      content = template('puma.rb')
      path = @env.root.join('config', 'puma.rb')
      create_file(path, content, backup: true)
    end

    def unicorn
      return nil unless @env.web_server == 'unicorn'

      content = template('unicorn.rb')
      path = @env.root.join('config', 'unicorn.rb')
      create_file(path, content, backup: true)
      regex = /gem\s+['"]unicorn['"]/
      ensure_line_in_file(gemfile_path, "gem 'unicorn'", regex: regex)
    end

    def database_yml
      return unless defined?(ActiveRecord)

      adapter = DockerCompose::ComposeConfiguration.database_adapter_name
      return if adapter == 'sqlite3'

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

    def env
      simple_copy('env', @env.root.join('.env'), overwrite: false)
    end

    def gitignore
      path = @env.root.join('.gitignore')
      globs = %w[.build/ .deploy/ Gemfile Gemfile.lock docker-compose.local.yml]
      lines = %w[orchestration/.sidecar .env deploy.tar] + globs.map do |line|
        "#{@env.orchestration_dir_name}/#{line}"
      end

      ensure_lines_in_file(path, lines)
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
      content = service_config_content(filename, config_class)
      path = @env.root.join('config', filename)
      if path.exist?
        update_file(path, content, backup: true)
      else
        create_file(path, content)
      end
    end

    def service_config_content(filename, config_class)
      template(
        filename,
        config: config_class.new(@env),
        compose: proc do |env|
          DockerCompose::ComposeConfiguration.new(
            Environment.new(environment: env)
          )
        end
      )
    end

    def dockerfile_content
      template(
        'Dockerfile',
        ruby_version: RUBY_VERSION,
        command: DockerCompose::AppService.command,
        entrypoint: DockerCompose::AppService.entrypoint,
        healthcheck: DockerCompose::AppService.healthcheck
      )
    end
  end
  # rubocop:enable Metrics/ClassLength
end
