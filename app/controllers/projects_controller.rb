# frozen_string_literal: true

class ProjectsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show sync]
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
    authorize @project, :explore?
    @pull_requests = @project.pull_requests.limit(10).order(updated_at: :desc)
    @branches = @project.branches.limit(10).order(updated_at: :desc)
  end

  def new
    authorize Project, :create?
    redirect_to connections_path, alert: "You need to connect to GitHub first." if current_user.github_access_token.blank?
    @project = current_user.projects.build
  end

  def edit
    find_project
    authorize @project, :update?
  end

  def create
    authorize Project, :create?
    @project = current_user.projects.build(project_params)
    if @project.save
      current_user.projects << @project
      @project.enqueue_fetch_config!
      # @project.enqueue_sync_data!
      redirect_to configure_project_path(@project), notice: "Project was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def configure
    find_project
    authorize @project, :update?
  end

  def sync
    find_project
    authorize @project, :sync?
    @project.enqueue_sync_data!
    redirect_to project_path(@project), notice: "Project is being synced."
  end

  def update
    find_project
    authorize @project, :update?

    if @project.update(project_params)
      @project.enqueue_sync_data!
      redirect_to project_path(@project), notice: "Project was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    find_project
    authorize @project

    @project&.destroy
    redirect_to projects_path, notice: "Project was successfully destroyed."
  end

  private

  def find_project
    @project = Project.find_by!(slug: params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :installation_remote_repository_id, :default_locale, :translations_path, :public, :allow_remote_contributors)
  end
end
