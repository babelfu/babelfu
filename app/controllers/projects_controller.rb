# frozen_string_literal: true

class ProjectsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]
  after_action :verify_authorized

  def index
    authorize Project
    @projects = Project.where(public: true, recognized: true).page(params[:page])
  end

  def user
    authorize Project
    @projects = current_user.projects.page(params[:page])
  end

  def show
    find_project
    authorize @project
    @pull_requests = @project.pull_requests.limit(10).order(updated_at: :desc)
    @branches = @project.branches.limit(10).order(updated_at: :desc)
  end

  def new
    authorize Project
    redirect_to connections_path, alert: "You need to connect to GitHub first." if current_user.github_access_token.blank?
    @project = current_user.projects.build
  end

  def sync
    find_project
    authorize @project
    @project.enqueue_sync_data!
    redirect_to project_path(@project), notice: "Project is being synced."
  end

  def edit
    find_project
  end

  def create
    authorize Project
    installation_id, remote_repository_id = params[:project][:remote_repository_id].split(":")
    @project = current_user.projects.build(project_params)
    @project.installation_id = installation_id
    @project.remote_repository_id = remote_repository_id
    @project.slug = Random.uuid
    if @project.save
      current_user.projects << @project
      @project.enqueue_sync_data!
      redirect_to project_path(@project), notice: "Project was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    find_project
    if @project.update(project_params)
      @project.enqueue_sync_data!
      redirect_to project_path(@project), notice: "Project was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    find_project
    @project&.destroy
    redirect_to projects_path, notice: "Project was successfully destroyed."
  end

  private

  def find_project
    @project = Project.find_by!(slug: params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :remote_repository_id, :default_locale, :translations_path)
  end
end
