# frozen_string_literal: true

# == Schema Information
#
# Table name: translations
#
#  id          :bigint           not null, primary key
#  branch_ref  :string
#  branch_refs :string           default([]), is an Array
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
#  index_translations_on_project_id                               (project_id)
#  index_translations_on_project_id_and_key_and_locale_and_value  (project_id,key,locale,value) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#
class Translation < ApplicationRecord
  belongs_to :project
end
