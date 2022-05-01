# frozen_string_literal: true

require 'orchestration'

namespace :orchestration do
  desc I18n.t('orchestration.rake.install')
  task :install do
    Orchestration::InstallGenerator.start
  end

  desc I18n.t('orchestration.makefile')
  task :makefile do
    Orchestration.makefile
  end

  desc I18n.t('orchestration.rake.config')
  task :config do
    config = YAML.safe_load(File.read('.orchestration.yml'))
    puts "#{config['docker']['organization']} #{config['docker']['repository']}"
  end

  desc I18n.t('orchestration.rake.upgrade')
  task :upgrade do
    terminal = Orchestration::Terminal.new(Orchestration::Environment.new.settings)
    %w[
      orchestration/docker-compose.yml
      orchestration/docker-compose.override.yml
      orchestration/Makefile
      orchestration/deploy.mk
      orchestration/yaml.bash
      orchestration/healthcheck.rb
    ].each.map { |path| Pathname.new(path) }.each do |path|
      next unless path.exist?

      terminal.write(:delete, path)
      path.unlink
    end

    src  = 'orchestration/docker-compose.production.yml'
    dest = 'orchestration/docker-compose.deployment.yml'
    if File.exist?(src)
      terminal.write(:rename, "#{src} => #{dest}")
      File.rename(src, dest)
    end

    makefile = File.read('Makefile')
    makefile.gsub!(
      %r{^include orchestration/Makefile$},
      %[include $(shell bundle exec ruby -e 'require "orchestration/make"')]
    )
    makefile.gsub!(/^test: test-setup$/, 'test:')
    lines = makefile.lines(chomp: true)
    post_setup_start = lines.index('ifndef light')
    if post_setup_start.nil?
      updated_makefile = lines.join("\n")
      post_setup = []
    else
      post_setup_end = post_setup_start + lines[post_setup_start..].index('endif')
      post_setup = lines[(post_setup_start + 1)...post_setup_end]
      updated_makefile = lines.each.with_index.reject do |_line, index|
        (post_setup_start..post_setup_end).cover?(index)
      end.map(&:first).join("\n")
    end
    if makefile.match(/^post-setup:$/).nil?
      updated_makefile += %(

.PHONY: post-setup
post-setup:
	@# Setup tasks that are not already provided by Orchestration go here.
#{post_setup.join("\n")}
)
    end
    if updated_makefile != makefile
      terminal.write(:update, 'Makefile')
      File.write('Makefile', updated_makefile)
    end

    %w[orchestration/docker-compose.test.yml orchestration/docker-compose.development.yml].each do |path|
      terminal.write(:update, path)
      config = YAML.safe_load(File.read(path))
      config['networks'] ||= {}
      config['networks']['local'] = { 'name' => '${COMPOSE_PROJECT_NAME}' }
      config['services'] ||= {}
      config['services'].each do |name, service|
        service['networks'] = { 'local' => { 'aliases' => [name] } }
      end
      File.write(path, config.to_yaml)
    end

    dockerfile_path = 'orchestration/Dockerfile'
    dockerfile = File.read(dockerfile_path)
    updated_dockerfile = dockerfile.dup
    updated_dockerfile.gsub!(
      'CMD ["ruby","/app/orchestration/healthcheck.rb"]',
      'CMD ["bundle","exec","rake","orchestration:healthcheck"]'
    )
    if updated_dockerfile != dockerfile
      terminal.write(:update, dockerfile_path)
      File.write(dockerfile_path, updated_dockerfile)
    end

    terminal.write(:success, 'Upgrade complete.')
    terminal.write(:info, '`make test` will now only run tests, skipping setup.')
    terminal.write(:info, 'Run `make setup test` to load test containers, run migrations, etc.')
    terminal.write(:info, 'Run `make setup` to load development environment.')
    terminal.write(:info, 'Run `make setup RAILS_ENV=test` to load test environment without running tests.')
    terminal.write(:info, 'Edit the `post-setup` recipe in `Makefile` to perform custom setup actions.')
  end

  namespace :db do
    desc I18n.t('orchestration.rake.db.url')
    task :url do
      config = Rails.application.config_for(:database).transform_keys(&:to_sym)

      if config[:adapter] == 'sqlite3'
        puts "sqlite3:#{config[:database]}"
      elsif !config[:url].nil?
        puts config[:url]
      else
        puts DatabaseUrl.to_active_record_url(config)
      end
    end

    desc I18n.t('orchestration.rake.db.console')
    task :console do
      env = Orchestration::Environment.new
      options = ENV['db'] ? { config_path: "config/database.#{ENV.fetch('db', nil)}.yml" } : {}
      sh Orchestration::Services::Database::Configuration.new(env, nil, options).console_command
    end
  end

  desc I18n.t('orchestration.rake.compose_services')
  task :compose_services do
    config = Orchestration::DockerCompose::ComposeConfiguration.new(Orchestration::Environment.new)
    puts config.services.keys.join(' ') unless config.services.nil? || config.services.empty?
  end

  desc I18n.t('orchestration.rake.healthcheck')
  task :healthcheck do
    Orchestration::DockerHealthcheck.execute
  end

  desc I18n.t('orchestration.rake.wait')
  task :wait do
    env = Orchestration::Environment.new
    services = Orchestration::Services
    env.docker_compose_config['services'].each do |name, _service|
      path = nil

      adapter = if name == 'database'
                  services::Database
                elsif name.include?('database')
                  path = "config/database.#{name.sub('database-', '')}.yml"
                  services::Database
                elsif name == 'mongo'
                  services::Mongo
                elsif name == 'rabbitmq'
                  services::RabbitMQ
                else
                  services::Listener
                end

      adapter::Healthcheck.start(
        nil, nil, config_path: path, service_name: name, sidecar: ENV.fetch('sidecar', nil)
      )
    end
  end
end
