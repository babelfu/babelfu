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

  INNER_JOIN_WITH_CHANGES = <<-SQL.squish
    INNER JOIN branches ON branches.name = proposals.branch_name
    LEFT JOIN translations
      ON translations.key = proposals.key
     AND translations.locale = proposals.locale
     AND translations.branch_name = proposals.branch_name
     AND translations.branch_ref = branches.ref
  SQL

  WHERE_WITH_CHANGES = <<-SQL.squish
    proposals.value != translations.value OR translations.value IS NULL
  SQL

  scope :with_changes, -> { joins(INNER_JOIN_WITH_CHANGES).distinct.where(WHERE_WITH_CHANGES) }

  def translation
    project.translations.find_by(key: key, locale: locale, branch_name: branch_name, branch_ref: branch_ref)
  end

  def branch
    project.branches.find_by(name: branch_name)
  end

  def branch_ref
    branch&.ref
  end

  def file_path
    translation&.file_path || File.join(project.translations_path, "#{locale}.yml")
  end
end
