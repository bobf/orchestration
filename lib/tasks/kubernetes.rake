# frozen_string_literal: true

namespace :orchestration do
  namespace :kubernetes do
    desc 'Create environment patch for a Kubernetes deployment'
    task :environment do
      env_file = File.expand_path(ENV.fetch('env_file', './.env'))
      if ENV['env_file'] && !File.exist?(env_file)
        warn "[\e[31mfail\e[39m] Env file does not exist: #{env_file}"
        exit 1
      elsif !File.exist?(env_file)
        env_file = nil
      end
      puts Orchestration::Kubernetes::Environment.new(env_file: env_file).content
    end

    desc 'Create image patch for a Kubernetes deployment'
    task :image do
      image = ENV.fetch('image')
      puts Orchestration::Kubernetes::Image.new(image: image).content
    end
  end
end
