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
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'database_url', '~> 0.1.2'
  spec.add_runtime_dependency 'erubis', '~> 2.7'
  spec.add_runtime_dependency 'i18n', '>= 0.5'
  spec.add_runtime_dependency 'paint', '~> 2.0'
end
