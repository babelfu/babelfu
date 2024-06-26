# frozen_string_literal: true

# == Schema Information
#
# Table name: metadata_users
#
#  id                   :bigint           not null, primary key
#  github_installations :json             not null
#  github_repositories  :json             not null
#  github_user          :json             not null
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

  def reset_github_metadata!
    update!(github_user: {}, github_repositories: {}, github_installations: [])
  end
end
