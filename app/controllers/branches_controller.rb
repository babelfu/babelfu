# frozen_string_literal: true

class BranchesController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :find_project
  after_action :verify_authorized

  def index
    authorize @project, :explore?
    @branches = @project.branches.page(params[:page]).order(updated_at: :desc)
  end

  def show
    find_branch
    authorize @project, :explore?

    @translations_presenter = TranslationsPresenter.new(@project,
                                                        branch_name: @branch.name,
                                                        **params.to_unsafe_h.merge(filter_locales: filter_locales))
  end

  def sync
    find_branch
    authorize @project, :sync?

    @branch.enqueue_sync!
  end

  def commits
    find_branch
    authorize @project, :commit?
    @commits_presenter = CommitsPresenter.new(project: @project, branch_name: @branch.name)
  end

  # TODO: DRY this up with pull requests controller
  def commit_create
    find_branch
    authorize @project, :commit?

    @commit_task = @project.commit_tasks.build
    @commit_task.branch_name = @branch.name

    if @commit_task.save
      CommitJob.enqueue_batch(@commit_task)
      flash[:notice] = "Commit task created"
    else
      flash[:error] = "There was an error creating the commit task"
    end

    redirect_to commits_project_branch_path(@project, @branch)
  end

  private

  def find_branch
    @branch = @project.branches.find_by(name: params[:id])
  end

  def find_project
    @project = Project.find_by!(slug: params[:project_id])
  end
end
