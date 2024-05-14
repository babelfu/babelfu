# frozen_string_literal: true

require "test_helper"

class CommitProposalsTest < ActiveSupport::TestCase
  test "wowo" do
    project = projects(:one)
    service = CommitProposals.new(project, "master")
    proposal_files = service.proposal_files

    file_path = proposal_files[0]
    data = service.data_for_file_path(file_path)
    service.generate_content(file_path, data)
  end
end
