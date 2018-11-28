# frozen_string_literal: true

module Orchestration
  class Settings
    def initialize(path)
      @path = path
      @dirty = false
      @exist = File.exist?(path)
    end

    def get(identifier)
      identifier.to_s.split('.').reduce(config) do |result, key|
        (result || {}).fetch(key)
      end
    rescue KeyError
      nil
    end

    def set(identifier, val)
      *keys, setting_key = identifier.to_s.split('.')
      new_config = config || {}
      parent = keys.reduce(new_config) { |result, key| result[key] ||= {} }
      parent[setting_key] = val
      @dirty ||= config != new_config
      File.write(@path, new_config.to_yaml)
    end

    def dirty?
      @dirty
    end

    def exist?
      @exist
    end

    private

    def config
      File.write(@path, {}.to_yaml) unless File.exist?(@path)
      YAML.safe_load(File.read(@path))
    end
  end
end
