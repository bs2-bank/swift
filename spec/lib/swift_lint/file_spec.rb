require "spec_helper"
require "swift_lint/file"

describe SwiftLint::File do
  describe ".in_tmpdir" do
    it "writes each file into the tmpdir and yields the dir" do
      file_one = SwiftLint::File.new("file-one.swift", "some content")
      file_two = SwiftLint::File.new("file-two.swift", "some content")

      SwiftLint::File.in_tmpdir(file_one, file_two) do |dir|
        expect(Dir.entries(dir)).to include("file-one.swift", "file-two.swift")
      end
    end
  end

  describe "#name" do
    it "returns basename from path" do
      file = SwiftLint::File.new("/some/path/file.swift", "")

      expect(file.name).to eq("file.swift")
    end
  end

  describe "#write_to_dir" do
    it "writes files in the given directory" do
      Dir.mktmpdir do |dir|
        file = SwiftLint::File.new("file.swift", "")

        file.write_to_dir(dir)

        expect(Dir.entries(dir)).to include("file.swift")
      end
    end
  end
end
