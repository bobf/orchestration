# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'orchestration/version'

Gem::Specification.new do |spec|
  url = 'https://github.com/bobf/orchestration'
  spec.name = 'orchestration'
  spec.version = Orchestration::VERSION
  spec.authors = ['Bob Farrell']
  spec.email = ['robertanthonyfarrell@gmail.com']

  spec.summary = 'Docker orchestration toolkit'
  spec.description = 'Tools to help launch apps in Docker'
  spec.homepage = url

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    File.readlines('MANIFEST').map(&:chomp)
  end
  spec.bindir = 'bin'
  spec.executables = []
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'database_url', '~> 0.1.2'
  spec.add_runtime_dependency 'erubis', '~> 2.7'
  spec.add_runtime_dependency 'i18n', '>= 0.5'
  spec.add_runtime_dependency 'paint', '~> 2.0'
  spec.add_runtime_dependency 'thor', '~> 1.0'

  spec.add_development_dependency 'activerecord', '~> 6.0'
  spec.add_development_dependency 'betterp', '~> 0.1.3'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'bunny', '~> 2.12'
  spec.add_development_dependency 'byebug', '~> 10.0'
  spec.add_development_dependency 'mongoid', '~> 7.0'
  spec.add_development_dependency 'mysql2', '~> 0.5.2'
  spec.add_development_dependency 'pg', '~> 1.1'
  spec.add_development_dependency 'rails', '~> 6.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-its', '~> 1.2'
  spec.add_development_dependency 'rubocop', '~> 0.77.0'
  spec.add_development_dependency 'sqlite3', '~> 1.3'
  spec.add_development_dependency 'strong_versions', '~> 0.3.1'
  spec.add_development_dependency 'webmock', '~> 3.4'
end
