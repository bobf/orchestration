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

    private

    def prompt(message, default)
      return "(#{message}): " if default.nil?

      "(#{message}) [#{I18n.t('orchestration.default')}: #{default}]: "
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
  end
end
