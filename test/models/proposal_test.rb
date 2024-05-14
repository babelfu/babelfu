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
end
