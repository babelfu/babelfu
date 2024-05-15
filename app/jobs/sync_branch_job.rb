# frozen_string_literal: true

class SyncBranchJob < ApplicationJob
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
