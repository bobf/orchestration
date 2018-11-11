# frozen_string_literal: true

module Orchestration
  COLOR_MAP = {
    failure: :light_red,
    error: :red,
    waiting: :yellow,
    ready: :green,
    database: :blue,
    create: :green,
    update: :yellow
  }.freeze

  class Terminal
    def write(desc, message = '')
      puts colorize(desc, message)
    end

    private

    def colorize(desc, message)
      desc
        .to_s
        .rjust(10)
        .colorize(mode: :default, color: COLOR_MAP[desc])
        .concat(' ' + message)
    end
  end
end
