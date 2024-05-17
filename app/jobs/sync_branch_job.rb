# frozen_string_literal: true

class SyncBranchJob < ApplicationJob
  include GoodJob::ActiveJobExtensions::Concurrency

  good_job_control_concurrency_with(
    perform_limit: 1,
    enqueue_limit: 2,
    enqueue_throttle: [10, 1.minute],
    key: -> { "#{self.class.name}:project_id:#{arguments.first.id}:branch_name:#{arguments.second}" }
  )

  queue_as :default

  def perform(project, branch_name)
    branch = project.branches.find_or_create_by!(name: branch_name)
    branch.sync_in_progress!

    FetchBranchTranslations.new(project, branch_name:).fetch!
    branch.sync_done!
  rescue StandardError => e
    branch.sync_failed!
    raise e
  end
end
