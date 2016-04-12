require "tmpdir"

module SwiftLint
  class File
    attr_reader :path, :content

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

    def write_to_dir(dir)
      temp_file_path = ::File.join(dir, path)
      FileUtils.mkdir_p(::File.dirname(temp_file_path))

      ::File.open(temp_file_path, "w") do |file|
        file.write(content)
      end
    end
  end
end
