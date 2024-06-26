# frozen_string_literal: true

class ProjectAcceptInvitationsController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    find_project
    @invitation = @project.invitations.find_by!(token: params[:token])

    store_location_for(:user, request.fullpath)
  end

  def join
    find_project
    @invitation = @project.invitations.find_by!(token: params[:token])

    if @invitation.accept!(current_user)
      redirect_to project_path(@project), notice: "You have successfully accepted the invitation."
    else
      render :show
    end
  end

  private

  def find_project
    @project = Project.find_by!(slug: params[:project_id])
  end
end
