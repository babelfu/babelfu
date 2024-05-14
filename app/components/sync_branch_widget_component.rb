# frozen_string_literal: true

class SyncBranchWidgetComponent < SyncWidgetComponent
  attr_reader :branch

  def initialize(branch)
    @branch = branch
  end

  def project
    @branch.project
  end

  def object
    branch
  end

  def sync_path
    sync_project_branch_path(project, branch)
  end

  def title
    "Sync translations"
  end
end
