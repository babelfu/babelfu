# frozen_string_literal: true

class ProjectInvitationsController < ApplicationController
  before_action :find_project!

  def index
    @invitations = @project.invitations.page(params[:page])
  end

  def new
    @invitation = @project.invitations.build
  end

  def create
    @invitation = @project.invitations.build(invitation_params)
    if @invitation.save
      ProjectMailer.with(invitation: @invitation).invitation_email.deliver_later
      redirect_to project_invitations_path(@project), notice: "Invitation sent"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def find_project!
    @project = current_user.projects.find(params[:project_id])
  end

  def invitation_params
    params.require(:project_invitation).permit(:email)
  end
end
