# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                              :bigint           not null, primary key
#  admin                           :boolean          default(FALSE)
#  email                           :string           default(""), not null
#  encrypted_password              :string           default(""), not null
#  github_access_token             :string
#  github_access_token_expires_at  :datetime
#  github_refresh_token            :string
#  github_refresh_token_expires_at :datetime
#  remember_created_at             :datetime
#  reset_password_sent_at          :datetime
#  reset_password_token            :string
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "person#{n}@example.com" }
    password { "password" }
  end
end
