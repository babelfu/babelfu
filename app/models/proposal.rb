# frozen_string_literal: true

# == Schema Information
#
# Table name: proposals
#
#  id          :bigint           not null, primary key
#  branch_name :string
#  key         :string
#  locale      :string
#  value       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  project_id  :bigint           not null
#
# Indexes
#
#  index_proposals_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#
class Proposal < ApplicationRecord
  belongs_to :project

  scope :with_changes, -> { joins("inner JOIN translations ON translations.key = proposals.key AND translations.locale = proposals.locale AND translations.branch_name = proposals.branch_name AND proposals.value != translations.value").distinct }

  def translation
    project.translations.find_by(key: key, locale: locale, branch_name: branch_name)
  end

  def file_path
    translation&.file_path || File.join(project.translations_path, "#{locale}.yml")
  end
end
