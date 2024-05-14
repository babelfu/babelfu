# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/project_mailer
class ProjectMailerPreview < ActionMailer::Preview
  def invitation_email
    invitation = ProjectInvitation.last
    ProjectMailer.with(invitation: invitation).invitation_email
  end
end
