# frozen_string_literal: true

module Orchestration
  module FileHelpers
    private

    def terminal
      @terminal ||= Terminal.new
    end

    def template_content(template, environment = {})
      file = Tempfile.new
      path = "#{file.path}.tt"
      file.close
      file.unlink
      template(template, path, environment.merge(verbose: false))
      File.read(path)
    end

    def delete_and_inject_after(path, pattern, replacement)
      return write_file(path, pattern + replacement) unless File.exist?(path)

      input = File.read(path)
      index = append_index(pattern, input)
      output = input[0...index] + pattern + replacement

      return terminal.write(:identical, relative_path(path)) if input == output

      update_file(path, output)
    end

    def append_index(pattern, input)
      return 0 if input.empty?

      index = input.index(pattern)
      index.nil? ? (input.size + 1) : index
    end

    def relative_path(path)
      path.relative_path_from(Rails.root).to_s
    end

    def write_file(path, content)
      File.write(path, content)
      terminal.write(:create, relative_path(path))
    end

    def update_file(path, content)
      File.write(path, content)
      terminal.write(:update, relative_path(path))
    end

    def append_file(path, content, echo: true)
      return write_file(path, content) unless File.exist?(path)

      File.write(path, content, File.size(path), mode: 'a')
      terminal.write(:update, relative_path(path)) if echo
    end

    def ensure_lines_in_file(path, lines)
      updated = lines.map do |line|
        ensure_line_in_file(path, line, echo: false)
      end.compact

      terminal.write(:update, relative_path(path)) if updated.any?
    end

    def ensure_line_in_file(path, line, echo: true)
      return if line_in_file?(path, line)

      append_file(path, "\n#{line.chomp}\n", echo: echo)
      true
    end

    def line_in_file?(path, line)
      return false unless File.exist?(path)

      File.readlines(path).map(&:chomp).include?(line.chomp)
    end
  end
end
