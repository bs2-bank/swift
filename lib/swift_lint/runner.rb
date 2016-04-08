require "swift_lint/violation"
require "swift_lint/system_call"

module SwiftLint
  class Runner
    def initialize(config, system_call: SystemCall.new)
      @config_file = File.new(".swiftlint.yml", config.to_yaml)
      @system_call = system_call
    end

    def violations_for(file)
      violation_strings(file).map do |violation_string|
        Violation.new(violation_string).to_hash
      end
    end

    private

    attr_reader :config_file, :system_call

    def violation_strings(file)
      result = execute_swiftlint(file).split("\n")
      result.select { |string| message_parsable?(string) }
    end

    def execute_swiftlint(file)
      File.in_tmpdir(file, config_file) do |dir|
        run_swiftlint_on_system(dir)
      end
    end

    def run_swiftlint_on_system(directory)
      Dir.chdir(directory) do
        system_call.call("swiftlint")
      end
    rescue SwiftLint::SystemCall::NonZeroExitStatusError => e
      e.output
    end

    def message_parsable?(string)
      SwiftLint::Violation.parsable?(string)
    end
  end
end
