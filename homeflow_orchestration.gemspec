# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'orchestration_orchestration/version'

Gem::Specification.new do |spec|
  url = 'https://bitbucket.org/orchestration_developers/orchestration_orchestration/src'
  spec.name = 'orchestration_orchestration'
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

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.59.2'
end
