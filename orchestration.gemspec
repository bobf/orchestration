# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'orchestration/version'

Gem::Specification.new do |spec|
  url = 'https://bitbucket.org/orchestration_developers/orchestration/src'
  spec.name = 'orchestration'
  spec.version = Orchestration::VERSION
  spec.authors = ['Bob Farrell']
  spec.email = ['bob@orchestration.co.uk']

  spec.summary = 'Docker orchestration toolkit'
  spec.description = 'Tools to help launch apps in Docker'
  spec.homepage = url

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir = 'bin'
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'colorize', '~> 0.8.1'
  spec.add_runtime_dependency 'erubis', '~> 2.7'
  spec.add_runtime_dependency 'i18n', '>= 0.5'
  spec.add_runtime_dependency 'unicorn', '~> 5.4'

  spec.add_development_dependency 'activerecord', '~> 5.2'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'bunny', '~> 2.12'
  spec.add_development_dependency 'byebug', '~> 10.0'
  spec.add_development_dependency 'mongoid', '~> 7.0'
  spec.add_development_dependency 'mysql2', '~> 0.5.2'
  spec.add_development_dependency 'pg', '~> 1.1'
  spec.add_development_dependency 'rails', '~> 5.2'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-its', '~> 1.2'
  spec.add_development_dependency 'rubocop', '~> 0.59.2'
  spec.add_development_dependency 'sqlite3', '~> 1.3'
  spec.add_development_dependency 'webmock', '~> 3.4'
end
