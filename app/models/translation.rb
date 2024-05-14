# frozen_string_literal: true

# == Schema Information
#
# Table name: translations
#
#  id          :bigint           not null, primary key
#  branch_name :string
#  branch_ref  :string
#  file_path   :string
#  key         :string
#  locale      :string
#  value       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  project_id  :bigint           not null
#
# Indexes
#
#  index_translations_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#
class Translation < ApplicationRecord
  belongs_to :project
end
