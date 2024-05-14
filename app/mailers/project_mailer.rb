# frozen_string_literal: true

class ProjectMailer < ApplicationMailer
  def invitation_email
    @invitation = params[:invitation]
    @project = @invitation.project
    mail to: @invitation.email, subject: "Invitation"
  end
end
