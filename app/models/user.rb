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
#  github_remote_id                :string
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  # TODO: check github_remote_id

  encrypts :github_access_token
  encrypts :github_refresh_token

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :memberships, dependent: :delete_all
  has_many :projects, through: :memberships
  has_one :metadata, class_name: "MetadataUser", dependent: :destroy
  def github_username
    metadata&.github_user&.dig("login")
  end

  def client
    @client ||= UserClient.new(self)
  end

  def save_github_access_token!(token)
    self.github_access_token = token["access_token"]
    self.github_access_token_expires_at = Time.current + token["expires_in"]
    self.github_refresh_token = token["refresh_token"]
    self.github_refresh_token_expires_at = Time.current + token["refresh_token_expires_in"]
    save!
  end

  def clear_github_connection!
    transaction do
      self.github_access_token = nil
      self.github_access_token_expires_at = nil
      self.github_refresh_token = nil
      self.github_refresh_token_expires_at = nil
      save!
      if metadata
        metadata.github_repositories = nil
        metadata.github_installations = nil
        metadata.github_user = nil
        metadata.save!
      end
    end
  end

  def github_remote_repositories_for_select
    github_remote_repositories.map { |k, v| [v[:repo]["full_name"], k] }
  end

  def github_remote_repositories
    @github_remote_repositories ||= begin
      mapping = {}
      metadata.github_repositories.each_pair do |installation_id, repos|
        repos.each do |repo|
          mapping["#{installation_id}:#{repo['full_name']}"] = { repo:, installation_id: }
        end
      end
      mapping
    end
  end
end
