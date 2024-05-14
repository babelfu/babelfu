# frozen_string_literal: true

class CommitsPresenter
  attr_reader :project, :branch_name

  def initialize(project:, branch_name:)
    @project = project
    @branch_name = branch_name
  end

  def commited_tasks
    @commited_tasks ||= @project.commit_tasks.where(branch_name:).where.not(commited_at: nil).order(id: :desc)
  end

  def commit_task_in_progress
    @commit_task_in_progress ||= @project.commit_tasks.where(branch_name:).where(commited_at: nil).first
  end

  def commit_task
    @commit_task ||= @project.commit_tasks.build(branch_name:)
  end
end
