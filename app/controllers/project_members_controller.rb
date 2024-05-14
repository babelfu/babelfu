# frozen_string_literal: true

class ProjectMembersController < ApplicationController
  before_action :find_project

  def index
    @users = @project.users.page(params[:page])
  end

  private

  def find_project
    @project = current_user.projects.find(params[:project_id])
  end
end
