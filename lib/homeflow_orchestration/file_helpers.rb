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
      output = input[0..index] + pattern + replacement

      File.write(path, output)
      terminal.write(:update, relative_path(path))
    end

    def append_index(pattern, input)
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

    def append_file(path, content)
      return write_file(path, content) unless File.exist?(path)

      File.write(path, content, File.size(path), mode: 'a')
      terminal.write(:update, relative_path(path))
    end

    def ensure_line_in_file(path, line)
      return if line_in_file?(path, line)

      append_file(path, "\n#{line.chomp}\n")
    end

    def line_in_file?(path, line)
      return false unless File.exist?(path)

      File.readlines(path).map(&:chomp).include?(line.chomp)
    end
  end
end
