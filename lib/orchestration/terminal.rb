# frozen_string_literal: true

module Orchestration
  COLOR_MAP = {
    failure: :light_red,
    error: :red,
    waiting: :yellow,
    ready: :green,
    create: :green,
    update: :yellow,
    identical: :blue,
    status: :blue
  }.freeze

  class Terminal
    def write(desc, message, color_name = nil)
      STDOUT.puts colorize(desc, message, color_name)
    end

    private

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
