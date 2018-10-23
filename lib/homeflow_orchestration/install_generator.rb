require 'thor'

module Orchestration
  class InstallGenerator < Thor::Group
    include Thor::Actions

    def makefile
      path = File.join(base_path, 'Makefile')
      content = template('Makefile')
      if File.exist?(path)
        delete_and_inject_after(path, '#!!orchestration_orchestration', content)
      else
        create_file 'Makefile', content
      end
    end

    def database_healthcheck
      create_file 'orchestration/database/healthcheck.rb',
                  template('database_healthcheck')

      create_file 'orchestration/database/wait',
                  template('database_healthcheck')
    end

    private

    def templates_path
      File.join(__dir__, 'templates/')
    end

    def template(name)
      File.read(File.join(templates_path, "#{name}.tt"))
    end

    def delete_and_inject_after(path, pattern, replacement)
      File.open(path, 'rw') do |file|
        input = file.read
        index = input.index(pattern)
        raise ArgumentError, 'Pattern not found' if index.nil?
        output = input[0..index] + pattern + replacement
        file.rewind
        file.write(output)
      end
    end
  end
end
