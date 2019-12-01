# frozen_string_literal: true

module Orchestration
  module FileHelpers
    private

    def orchestration_dir
      path = @env.orchestration_root
      FileUtils.mkdir(path) unless Dir.exist?(path)

      path
    end

    def template(template_name, context = {})
      Erubis::Eruby.new(read_template(template_name))
                   .result(context)
    end

    def inject_if_missing(path, content, index = 0)
      lines = File.exist?(path) ? File.readlines(path).map(&:chomp) : []
      if lines.any? { |line| line == content }
        return @terminal.write(:skip, relative_path(path))
      end

      lines.insert(index, content)
      update_file(path, lines.join("\n"))
    end

    def relative_path(path)
      path.relative_path_from(@env.root).to_s
    end

    def simple_copy(template_name, dest, options = {})
      update_file(
        dest,
        template(template_name, env: @env),
        overwrite: options.fetch(:overwrite, true)
      )
    end

    def create_file(path, content, options = {})
      relpath = relative_path(path)
      overwrite = options.fetch(:overwrite, true)
      present = File.exist?(path)
      return @terminal.write(:skip, relpath) if present && !overwrite && !force?

      write_file(path, content)
      @terminal.write(:create, relative_path(path))
    end

    def update_file(path, content, options = {})
      present = File.exist?(path)
      return create_file(path, content) unless present

      overwrite = options.fetch(:overwrite, true)
      previous_content = File.read(path) if present
      if present && ((!overwrite && !force?) || previous_content == content)
        return @terminal.write(:skip, relative_path(path))
      end

      File.write(path, content)
      @terminal.write(:update, relative_path(path))
    end

    def append_file(path, content, echo: true)
      return create_file(path, content) unless File.exist?(path)

      File.write(path, content, File.size(path), mode: 'a')
      @terminal.write(:update, relative_path(path)) if echo
    end

    def ensure_lines_in_file(path, lines)
      updated = lines.map do |line|
        ensure_line_in_file(path, line, echo: false)
      end.compact
      relpath = relative_path(path)

      return @terminal.write(:update, relpath) if updated.any?

      @terminal.write(:skip, relpath)
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

    def templates_path
      Orchestration.root.join('lib', 'orchestration', 'templates')
    end

    def read_template(template)
      File.read(templates_path.join("#{template}.erb"))
    end

    def write_file(path, content)
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, content)
    end

    def force?
      # Rake task was invoked with `force=yes`
      ENV['force'] == 'yes'
    end
  end
end
