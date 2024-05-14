# frozen_string_literal: true

# == Schema Information
#
# Table name: metadata_users
#
#  id                   :bigint           not null, primary key
#  github_installations :json
#  github_repositories  :json
#  github_user          :json
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :bigint           not null
#
# Indexes
#
#  index_metadata_users_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class MetadataUser < ApplicationRecord
  belongs_to :user
end
