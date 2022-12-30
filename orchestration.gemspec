# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'orchestration/version'

Gem::Specification.new do |spec|
  url = 'https://github.com/bobf/orchestration'
  spec.name = 'orchestration'
  spec.version = Orchestration::VERSION
  spec.authors = ['Bob Farrell']
  spec.email = ['git@bob.frl']

  spec.summary = 'Docker orchestration toolkit'
  spec.description = 'Tools to help launch apps in Docker'
  spec.homepage = url

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end

  spec.required_ruby_version = '~> 2.6'
  spec.bindir = 'bin'
  spec.executables = []
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'database_url', '~> 0.1.2'
  spec.add_runtime_dependency 'dotenv-rails', '~> 2.8'
  spec.add_runtime_dependency 'erubis', '~> 2.7'
  spec.add_runtime_dependency 'i18n', '>= 0.5'
  spec.add_runtime_dependency 'paint', '~> 2.0'
  spec.add_runtime_dependency 'thor', '~> 1.0'

  spec.add_development_dependency 'activerecord', '~> 6.0'
  spec.add_development_dependency 'bunny', '~> 2.12'
  spec.add_development_dependency 'devpack', '~> 0.3.2'
  spec.add_development_dependency 'mongoid', '~> 7.0'
  spec.add_development_dependency 'mysql2', '~> 0.5.2'
  spec.add_development_dependency 'pg', '~> 1.1'
  spec.add_development_dependency 'rails', '~> 6.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-its', '~> 1.2'
  spec.add_development_dependency 'rubocop', '~> 1.12'
  spec.add_development_dependency 'rubocop-rails', '~> 2.9'
  spec.add_development_dependency 'rubocop-rake', '~> 0.5.1'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.2'
  spec.add_development_dependency 'sqlite3', '~> 1.3'
  spec.add_development_dependency 'strong_versions', '~> 0.4.5'
  spec.add_development_dependency 'webmock', '~> 3.4'
end
