# frozen_string_literal: true

# == Schema Information
#
# Table name: project_invitations
#
#  id          :bigint           not null, primary key
#  accepted_at :datetime
#  email       :string
#  token       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  project_id  :bigint           not null
#
# Indexes
#
#  index_project_invitations_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#
require "test_helper"

class ProjectInvitationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
