require "open3"

module SwiftLint
  class SystemCall
    class NonZeroExitStatusError < StandardError
      attr_reader :output

      def initialize(message, output)
        super(message)
        @output = output
      end
    end

    def call(cmd)
      run_command(cmd)

      if last_command_successful?
        command_output
      else
        raise NonZeroExitStatusError.new("Command: '#{cmd}'", command_output)
      end
    end

    private

    attr_reader :command_output, :command_status

    def run_command(cmd)
      @command_output, @command_status = Open3.capture2e(cmd)
    end

    def last_command_successful?
      command_status.success?
    end
  end
end
