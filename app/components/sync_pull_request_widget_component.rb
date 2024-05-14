# frozen_string_literal: true

class SyncPullRequestWidgetComponent < SyncWidgetComponent
  attr_reader :pull_request

  def initialize(pull_request)
    @pull_request = pull_request
  end

  def project
    @pull_request.project
  end

  def object
    pull_request
  end

  def sync_path
    sync_project_pull_request_path(project, pull_request)
  end

  def title
    "Sync translations"
  end
end
