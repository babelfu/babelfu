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
class ProjectInvitation < ApplicationRecord
  belongs_to :project
  has_secure_token

  # TODO: review the email validation
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  scope :pending, -> { where(accepted_at: nil) }

  def status
    accepted_at.present? ? :accepted : :pending
  end

  def accept!(user)
    transaction do
      project.users << user
      self.accepted_at = Time.current
      save!
    end
  end
end
