# frozen_string_literal: true

module Orchestration
  COLOR_MAP = {
    failure: :light_red,
    error: :red,
    waiting: :yellow,
    ready: :green,
    create: :green,
    update: :yellow,
    status: :blue,
    setup: :blue,
    input: :red,
    skip: :light_yellow
  }.freeze

  class Terminal
    def initialize(settings)
      @settings = settings
    end

    def write(desc, message, color_name = nil, newline = true)
      output = newline ? "#{message}\n" : message.to_s
      STDOUT.print colorize(desc, output, color_name)
    end

    def read(message, default = nil)
      write(:input, prompt(message, default), nil, false)
      result = STDIN.gets.chomp.strip
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
      desc
        .to_s
        .rjust(15)
        .colorize(mode: :default, color: color)
        .concat(' ' + message)
    end

    def t(key)
      I18n.t("orchestration.#{key}")
    end
  end
end
