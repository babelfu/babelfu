# frozen_string_literal: true

# == Schema Information
#
# Table name: proposals
#
#  id          :bigint           not null, primary key
#  branch_name :string
#  key         :string
#  locale      :string
#  value       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  project_id  :bigint           not null
#
# Indexes
#
#  index_proposals_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#
require "test_helper"

class ProposalTest < ActiveSupport::TestCase
  test "file_path with an existing translation" do
    proposal = proposals(:es_hello)
    assert_equal "config/locales/es.yml", proposal.file_path
  end

  test "file_path without a translation" do
    # returns a default file path for the locale

    proposal = proposals(:es_bye)
    assert_equal "config/locales/es.yml", proposal.file_path
  end

  test "with_changes scope" do
    project = Project.create!(remote_repository_id: "foo/bar")
    project.branches.create!(name: "main", ref: "main_aaa")
    project.translations.create!(key: "hello", value: "Hello", locale: "es", branch_name: "main", branch_ref: "main_aaa")

    # A proposal for an existing translation
    proposal1 = project.proposals.create!(key: "hello", value: "Hola", locale: "es", branch_name: "main")

    # proposal for the same key in a different locale
    proposal2 = project.proposals.create!(key: "hello", value: "hello", locale: "en", branch_name: "main")

    # A proposal for a new key in the same locale
    proposal3 = project.proposals.create!(key: "new_key", value: "A new key", locale: "es", branch_name: "main")

    assert_equal [proposal1, proposal2, proposal3], project.proposals.with_changes
  end
end
