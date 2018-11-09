require 'thor'
require 'tempfile'

module Orchestration
  class InstallGenerator < Thor::Group
    include Thor::Actions

    def self.source_root
      Orchestration.root.join(
        'lib', 'orchestration_orchestration', 'templates'
      )
    end

    def makefile
      environment = { app_id: 'testing' }
      content = template_content('Makefile', environment)
      path = 'Makefile'
      delete_and_inject_after(path, "#!!orchestration_orchestration\n", content)
    end

    private

    def template_content(template, environment)
      file = Tempfile.new
      path = file.path
      file.close
      file.unlink
      template('Makefile', path, environment.merge(verbose: false))
      File.read(path)
    end

    def delete_and_inject_after(path, pattern, replacement)
      return File.write(path, pattern + replacement) unless File.exist?(path)

      input = File.read(path)
      index = input.index(pattern)
      raise ArgumentError, 'Pattern not found' if index.nil?
      output = input[0..index] + pattern + replacement

      create_file(path, output)
    end
  end
end
