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
    def write(desc, message = '')
      puts colorize(desc, message)
    end

    private

    def colorize(desc, message, color_name = nil)
      color = color_name.nil? ? COLOR_MAP[desc] : COLOR_MAP[color_name]
      desc
        .to_s
        .rjust(15)
        .colorize(mode: :default, color: color)
        .concat(' ' + message)
    end
  end
end
