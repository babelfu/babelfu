# frozen_string_literal: true

# == Schema Information
#
# Table name: metadata_projects
#
#  id                   :bigint           not null, primary key
#  github_collaborators :json
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  project_id           :bigint           not null
#
# Indexes
#
#  index_metadata_projects_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#
require "test_helper"

class MetadataProjectTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
