# frozen_string_literal: true

class SyncBranchFileJob < ApplicationJob
  include GoodJob::ActiveJobExtensions::Batches
  include GoodJob::ActiveJobExtensions::Concurrency
  queue_as :default

  good_job_control_concurrency_with(
    # Maximum number of unfinished jobs to allow with the concurrency key
    # Can be an Integer or Lambda/Proc that is invoked in the context of the job
    total_limit: 1,

    # Maximum number of jobs with the concurrency key to be
    # concurrently performed (excludes enqueued jobs)
    # Can be an Integer or Lambda/Proc that is invoked in the context of the job
    perform_limit: 1,
    key: -> { "#{self.class.name}-#{arguments}" }
  )

  def perform(project:, branch_name:, branch_ref:, file_path:, file_path_ref:)
    service = FetchTranslations.new(project, branch_name)
    data = service.get_translations_from_file_path_ref(file_path, file_path_ref)
    translations = data.map do |item|
      item.merge(branch_name: branch_name, branch_ref: branch_ref)
    end

    project.translations.upsert_all(translations, unique_by: %i[project_id key locale branch_ref])
  end
end
