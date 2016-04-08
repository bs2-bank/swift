require "spec_helper"
require "config_options"
require "swift_lint/runner"
require "swift_lint/file"

describe SwiftLint::Runner do
  describe "#violations_for" do
    it "executes proper command to get violations" do
      config = ConfigOptions.new("")
      file = SwiftLint::File.new("file.swift", "let x = 'Hello'")
      system_call = SwiftLint::SystemCall.new
      allow(system_call).to receive(:call).and_return("")
      runner = SwiftLint::Runner.new(config, system_call: system_call)

      runner.violations_for(file)

      expect(system_call).to have_received(:call).with("swiftlint")
    end

    if RUBY_PLATFORM =~ /darwin/
      it "returns all violations" do
        config = ConfigOptions.new("")
        file = SwiftLint::File.new("file.swift", swift_file_content)
        runner = SwiftLint::Runner.new(config)

        violations = runner.violations_for(file)

        expect(violations.size).to eq(6)
      end

      describe "file with major violations" do
        it "returns all violations" do
          config = ConfigOptions.new("")
          file = SwiftLint::File.new("file.swift", swift_major_file_content)
          runner = SwiftLint::Runner.new(config)

          violations = runner.violations_for(file)

          expect(violations.size).to eq(1)
        end
      end
    end
  end

  def swift_file_content
    <<-SWIFT
/**
    this line violates the line length contraint. this line violates the line length contraint. this line violates the line length contraint.
    it also validates valid_docs
*/
public func <*> <T, U>(f: (T -> U)?, a: T?) -> U? {
    print('using a function wrapped in single quotes')
    print('using a function wrapped in double quotes')
    print('using backticks `')
    let colonOnWrongSide :Int = 0 as! Int
    return a.apply(f)
}
    SWIFT
  end

  def swift_major_file_content
    <<-SWIFT
class ShortVariableName {
  func tooShort(a: Int) {
    print("I am too short \(a)")
  }
}
    SWIFT
  end
end
