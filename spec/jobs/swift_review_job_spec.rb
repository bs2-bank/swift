require "spec_helper"
require "jobs/swift_review_job"

describe SwiftReviewJob do
  describe ".perform" do
    it "enqueues review job with violations" do
      config = ConfigOptions.new("")
      runner = SwiftLint::Runner.new(config)
      allow(Resque).to receive(:enqueue)
      allow(SwiftLint::Runner).to receive(:new).and_return(runner)
      allow(runner).
        to receive(:execute_swiftlint).and_return(swiftlint_response)

      SwiftReviewJob.perform(
        "filename" => "test.swift",
        "commit_sha" => "123abc",
        "pull_request_number" => "123",
        "patch" => "test",
        "content" => "let number = 1 \n",
      )

      expect(Resque).to have_received(:enqueue).with(
        CompletedFileReviewJob,
        filename: "test.swift",
        commit_sha: "123abc",
        pull_request_number: "123",
        patch: "test",
        violations: [
          { line: 1, message: whitespace_violation_message },
        ]
      )
    end

    def whitespace_violation_message
      "Trailing Whitespace Violation (Medium Severity): " \
        "Line #1 should have no trailing whitespace: " \
        "current has 1 trailing whitespace characters"
    end

    def swiftlint_response
      "Loading configuration from /tmp/hound_swiftlint_config\n" \
        "<nopath>:1: warning: " \
        "Trailing Whitespace Violation (Medium Severity): " \
        "Line #1 should have no trailing whitespace: " \
        "current has 1 trailing whitespace characters\n"
    end
  end
end
