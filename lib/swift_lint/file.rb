require "tmpdir"

module SwiftLint
  class File
    attr_reader :content

    def initialize(path, content)
      @path = path
      @content = content
    end

    def self.in_tmpdir(*files)
      Dir.mktmpdir do |dir|
        files.each { |file| file.write_to_dir(dir) }
        yield dir
      end
    end

    def name
      ::File.basename(path)
    end

    def write_to_dir(dir)
      ::File.open(::File.join(dir, name), "w") do |file|
        file.write(content)
      end
    end

    private

    attr_reader :path
  end
end
