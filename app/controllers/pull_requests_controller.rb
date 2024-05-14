# frozen_string_literal: true

class PullRequestsController < ApplicationController
  before_action :find_project

  def show
    @pull_request = @project.pull_requests.find_by(remote_id: params[:id])
    @translations_presenter = TranslationsPresenter.new(@project,
                                                        branch_name: @pull_request.head_branch_name,
                                                        base_branch_name: @pull_request.base_branch_name,
                                                        **params.to_unsafe_h)
  end

  def sync
    find_pull_request

    @pull_request.enqueue_sync!
    redirect_back(fallback_location: project_pull_request_path(@project, @pull_request))
  end

  # TODO: DRY this up with branches controller
  def commit_create
    find_pull_request

    @commit_task = @project.commit_tasks.build
    @commit_task.branch_name = @pull_request.head_branch_name

    if @commit_task.save
      CommitJob.perform_later(@commit_task)
      flash[:notice] = "Commit task created"
    else
      flash[:error] = "There was an error creating the commit task"
    end

    redirect_to commits_project_pull_request_path(@project, @pull_request)
  end

  def commits
    find_pull_request

    @commits_presenter = CommitsPresenter.new(project: @project, branch_name: @pull_request.head_branch_name)
  end

  private

  def find_pull_request
    @pull_request = @project.pull_requests.find_by(remote_id: params[:id])
  end

  def find_project
    @project = current_user.projects.find(params[:project_id])
  end
end
