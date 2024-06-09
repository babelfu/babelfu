# frozen_string_literal: true

class PullRequestsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :find_project
  after_action :verify_authorized

  def index
    authorize @project, :explore?
    @pull_requests = @project.pull_requests.page(params[:page]).order(updated_at: :desc)
  end

  def show
    authorize @project, :explore?
    find_pull_request

    @translations_presenter = TranslationsPresenter.new(@project,
                                                        branch_name: @pull_request.head_branch_name,
                                                        base_branch_name: @pull_request.base_branch_name,
                                                        **params.to_unsafe_h.merge(filter_locales: filter_locales))
  end

  def sync
    authorize @project, :sync?
    find_pull_request

    @pull_request.enqueue_sync!
  end

  # TODO: DRY this up with branches controller
  def commit_create
    authorize @project, :commit?
    find_pull_request

    @commit_task = @project.commit_tasks.build
    @commit_task.branch_name = @pull_request.head_branch_name

    if @commit_task.save
      CommitJob.enqueue_batch(@commit_task)
      flash[:notice] = "Commit task created"
    else
      flash[:error] = "There was an error creating the commit task"
    end

    redirect_to commits_project_pull_request_path(@project, @pull_request)
  end

  def commits
    authorize @project, :commit?
    find_pull_request

    @commits_presenter = CommitsPresenter.new(project: @project, branch_name: @pull_request.head_branch_name)
  end

  private

  def find_pull_request
    @pull_request = @project.pull_requests.find_by(remote_id: params[:id])
  end

  def find_project
    @project = Project.find_by!(slug: params[:project_id])
  end
end
