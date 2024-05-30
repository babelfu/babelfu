# frozen_string_literal: true

class SyncBranchFileJob < ApplicationJob
  include GoodJob::ActiveJobExtensions::Batches
  queue_as :default

  def perform(project:, branch_name:, branch_ref:, file_path:, file_path_ref:)
    service = FetchTranslations.new(project, branch_name)
    data = service.get_translations_from_file_path_ref(file_path, file_path_ref)
    translations = data.map do |item|
      item.merge(branch_ref: branch_ref)
    end

    UpsertTranslations.call(project, translations)
  end
end
