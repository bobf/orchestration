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
      return unless build?('.orchestration.yml')

      configure_orchestration_settings
      relpath = relative_path(@env.orchestration_configuration_path)
      return @terminal.write(:create, relpath) unless @settings.exist? || force?
      return @terminal.write(:update, relpath) if @settings.dirty?

      @terminal.write(:skip, relpath)
    end

    def application_makefile
      return unless build?('Makefile')

      path = @env.root.join('Makefile')
      simple_copy('application.mk', path) unless File.exist?(path)
    end

    def dockerfile
      return unless build?('Dockerfile')

      create_file(
        orchestration_dir.join('Dockerfile'),
        dockerfile_content,
        overwrite: false
      )
    end

    def entrypoint_sh
      return unless build?('entrypoint.sh')

      content = template('entrypoint.sh')
      path = orchestration_dir.join('entrypoint.sh')
      create_file(path, content, overwrite: false)
      FileUtils.chmod('a+x', path)
    end

    def docker_compose
      return unless build?('docker-compose.yml')

      @docker_compose.docker_compose_test_yml
      @docker_compose.docker_compose_development_yml
      @docker_compose.docker_compose_deployment_yml
    end

    def puma
      return unless build?('puma.rb')
      return nil unless @env.web_server == 'puma'

      content = template('puma.rb')
      path = @env.root.join('config', 'puma.rb')
      create_file(path, content, backup: true)
    end

    def unicorn
      return unless build?('unicorn.rb')
      return nil unless @env.web_server == 'unicorn'

      content = template('unicorn.rb')
      path = @env.root.join('config', 'unicorn.rb')
      create_file(path, content, backup: true)
      regex = /gem\s+['"]unicorn['"]/
      ensure_line_in_file(gemfile_path, "gem 'unicorn'", regex: regex)
    end

    def database_yml
      return unless build?('database.yml')
      return unless defined?(ActiveRecord)

      adapter = DockerCompose::ComposeConfiguration.database_adapter_name
      return if adapter == 'sqlite3'

      service_config('database.yml', Services::Database::Configuration)
    end

    def mongoid_yml
      return unless build?('mongoid.yml')
      return unless defined?(Mongoid)

      service_config('mongoid.yml', Services::Mongo::Configuration)
    end

    def rabbitmq_yml
      return unless build?('rabbitmq.yml')
      return unless defined?(Bunny)

      service_config('rabbitmq.yml', Services::RabbitMQ::Configuration)
    end

    def env
      return unless build?('.env')

      simple_copy('env', @env.root.join('.env'), overwrite: false)
    end

    def gitignore
      return unless build?('.gitignore')

      path = @env.root.join('.gitignore')
      globs = %w[.build/ .deploy/ Gemfile Gemfile.lock docker-compose.local.yml]
      lines = %w[orchestration/.sidecar .env deploy.tar] + globs.map do |line|
        "#{@env.orchestration_dir_name}/#{line}"
      end

      ensure_lines_in_file(path, lines)
    end

    private

    def build?(filename)
      return true unless ENV.key?('build')
      return true if ENV.fetch('build') == filename

      false
    end

    def t(key)
      I18n.t("orchestration.#{key}")
    end

    def enabled_services
      %i[test development deployment].map do |environment|
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

    def configure_orchestration_settings
      @terminal.ask_setting(
        'docker.organization',
        override: ENV.fetch('organization', nil)
      )

      @terminal.ask_setting(
        'docker.repository',
        default: @env.default_app_name,
        override: ENV.fetch('project', nil)
      )
    end
  end
  # rubocop:enable Metrics/ClassLength
end
