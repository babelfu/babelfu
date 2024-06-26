# frozen_string_literal: true

class ProjectMembersController < ApplicationController
  before_action :find_project
  after_action :verify_authorized

  def index
    authorize @project, :list_members?
    @users = @project.users.page(params[:page])
  end

  private

  def find_project
    @project = current_user.projects.find_by!(slug: params[:project_id])
  end
end
