# frozen_string_literal: true

module Orchestration
  COLOR_MAP = {
    failure: %i[red bright],
    success: %i[green],
    info: %i[blue],
    error: %i[red],
    ready: %i[green],
    create: %i[green],
    delete: %i[red],
    rename: %i[blue],
    update: %i[yellow],
    backup: %i[blue],
    status: %i[blue],
    setup: %i[blue],
    input: %i[red],
    skip: %i[yellow bright],
    waiting: %i[yellow],
    config: %i[cyan]
  }.freeze

  class Terminal
    def initialize(settings)
      @settings = settings
    end

    def write(desc, message = nil, color_name = nil, newline: true)
      output = newline ? "#{message}\n" : message.to_s
      $stdout.print colorize(desc, output, color_name)
      $stdout.flush
    end

    def read(message, default = nil)
      write(:input, prompt(message, default), nil, newline: false)
      result = $stdin.gets.chomp.strip
      return default if result.empty?

      result
    end

    def ask_setting(setting, default = nil)
      return unless @settings.get(setting).nil?

      write(:setup, t("settings.#{setting}.description"))
      prompt = t("settings.#{setting}.prompt")
      @settings.set(setting, read(prompt, default))
    end

    private

    def prompt(message, default)
      return "(#{message}): " if default.nil?

      "(#{message}) [#{t('default')}: #{default}]: "
    end

    def colorize(desc, message, color_name)
      color = if color_name.nil?
                COLOR_MAP.fetch(desc)
              else
                COLOR_MAP.fetch(color_name)
              end

      "#{Paint[desc.to_s.rjust(15), *color]} #{message}"
    end

    def t(key)
      I18n.t("orchestration.#{key}")
    end
  end
end
