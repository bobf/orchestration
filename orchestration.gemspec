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
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end

  spec.required_ruby_version = '>= 3.1'
  spec.bindir = 'bin'
  spec.executables = []
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'database_url', '~> 0.1.2'
  spec.add_runtime_dependency 'dotenv-rails', '~> 2.8'
  spec.add_runtime_dependency 'erubis', '~> 2.7'
  spec.add_runtime_dependency 'i18n'
  spec.add_runtime_dependency 'paint', '~> 2.2'
  spec.add_runtime_dependency 'rails', '>= 6.1'
  spec.add_runtime_dependency 'thor', '~> 1.2'

  spec.add_development_dependency 'activerecord', '>= 6.0'
  spec.add_development_dependency 'activerecord-postgis-adapter', '~> 8.0'
  spec.add_development_dependency 'bunny', '~> 2.19'
  spec.add_development_dependency 'devpack', '~> 0.4.0'
  spec.add_development_dependency 'mongoid', '~> 7.4'
  spec.add_development_dependency 'mysql2', '~> 0.5.3'
  spec.add_development_dependency 'pg', '~> 1.3'
  spec.add_development_dependency 'rails'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'redis', '~> 4.6'
  spec.add_development_dependency 'rspec', '~> 3.11'
  spec.add_development_dependency 'rspec-its', '~> 1.3'
  spec.add_development_dependency 'rubocop', '~> 1.28'
  spec.add_development_dependency 'rubocop-rails', '~> 2.14'
  spec.add_development_dependency 'rubocop-rake', '~> 0.6.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.10'
  spec.add_development_dependency 'sqlite3', '~> 1.4'
  spec.add_development_dependency 'strong_versions', '~> 0.4.5'
  spec.add_development_dependency 'webmock', '~> 3.14'
end
