# frozen_string_literal: true

class ProjectsController < ApplicationController
  def index
    @projects = current_user.projects.page(params[:page])
  end

  def show
    @project = current_user.projects.find(params[:id])
  end

  def new
    redirect_to connections_path, alert: "You need to connect to GitHub first." if current_user.github_access_token.blank?
    @project = current_user.projects.build
  end

  def sync
    @project = current_user.projects.find(params[:id])
    @project.enqueue_sync_data!
    redirect_to project_path(@project), notice: "Project is being synced."
  end

  def edit
    @project = current_user.projects.find(params[:id])
  end

  def create
    installation_id, remote_repository_id = params[:project][:remote_repository_id].split(":")
    @project = current_user.projects.build(project_params)
    @project.installation_id = installation_id
    @project.remote_repository_id = remote_repository_id
    if @project.save
      current_user.projects << @project
      @project.enqueue_sync_data!
      redirect_to project_path(@project), notice: "Project was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @project = current_user.projects.find(params[:id])
    if @project.update(project_params)
      @project.enqueue_sync_data!
      redirect_to project_path(@project), notice: "Project was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project = current_user.projects.find_by(id: params[:id])
    @project&.destroy
    redirect_to projects_path, notice: "Project was successfully destroyed."
  end

  private

  def project_params
    params.require(:project).permit(:name, :remote_repository_id, :default_locale, :translations_path)
  end
end
