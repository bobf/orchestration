# frozen_string_literal: true

require 'thor'
require 'tempfile'

module Orchestration
  class InstallGenerator < Thor::Group
    include FileHelpers

    def initialize(*_args)
      super
      @env = Environment.new
      @terminal ||= Terminal.new
      @settings = Settings.new(@env.orchestration_configuration_path)
    end

    def orchestration_configuration
      path = @env.orchestration_configuration_path
      ask_setting('docker.username')
      ask_setting('docker.repository', @env.default_application_name)
      relpath = relative_path(path)
      return @terminal.write(:create, relpath) unless @settings.exist?
      return @terminal.write(:update, relpath) if @settings.dirty?

      @terminal.write(:skip, relpath)
    end

    def makefile
      environment = { env: @env, wait_commands: wait_commands }
      content = template('Makefile', environment)
      path = @env.orchestration_root.join('Makefile')
      path.exist? ? update_file(path, content) : create_file(path, content)
      inject_if_missing(
        @env.root.join('Makefile'),
        'include orchestration/Makefile'
      )
    end

    def dockerfile
      content = template('Dockerfile', ruby_version: RUBY_VERSION)
      create_file(
        orchestration_dir.join('Dockerfile'),
        content,
        overwrite: false
      )
    end

    def entrypoint
      content = template('entrypoint.sh')
      path = orchestration_dir.join('entrypoint.sh')
      create_file(path, content, overwrite: false)
      FileUtils.chmod('a+x', path)
    end

    def gitignore
      path = @env.root.join('.gitignore')
      entries = %w[.build/ Gemfile Gemfile.lock *.gemspec].map do |entry|
        "#{@env.orchestration_dir_name}/#{entry}"
      end

      ensure_lines_in_file(path, entries)
    end

    def docker_compose
      path = @env.orchestration_root.join('docker-compose.yml')
      return if File.exist?(path)

      docker_compose = DockerCompose::Services.new(@env, service_configurations)
      create_file(path, docker_compose.structure.to_yaml)
    end

    def unicorn
      content = template('unicorn.rb')
      path = @env.root.join('config', 'unicorn.rb')
      create_file(path, content, overwrite: false)
    end

    def yaml_bash
      simple_copy('yaml.bash', @env.orchestration_root.join('yaml.bash'))
    end

    private

    def t(key)
      I18n.t("orchestration.#{key}")
    end

    def service_configurations
      Hash[
        %i[application database mongo rabbitmq nginx_proxy].map do |key|
          [key, configuration(key)]
        end
      ]
    end

    def configuration(service)
      {
        application: Services::Application::Configuration,
        database: Services::Database::Configuration,
        mongo: Services::Mongo::Configuration,
        rabbitmq: Services::RabbitMQ::Configuration,
        nginx_proxy: Services::NginxProxy::Configuration
      }.fetch(service).new(@env)
    end

    def wait_commands
      [
        configuration(:database).settings.nil? ? nil : 'wait-database',
        configuration(:mongo).settings.nil? ? nil : 'wait-mongo',
        configuration(:rabbitmq).settings.nil? ? nil : 'wait-rabbitmq',
        'wait-nginx-proxy',
        'wait-application'
      ].compact.join(' ')
    end

    def ask_setting(setting, default = nil)
      return unless @settings.get(setting).nil?

      @terminal.write(:setup, t("settings.#{setting}.description"))
      prompt = t("settings.#{setting}.prompt")
      @settings.set(setting, @terminal.read(prompt, default))
    end
  end
end
