# frozen_string_literal: true

# == Schema Information
#
# Table name: projects
#
#  id                             :bigint           not null, primary key
#  default_branch_name            :string
#  default_locale                 :string
#  github_access_token            :string
#  github_access_token_expires_at :datetime
#  name                           :string
#  public                         :boolean          default(FALSE)
#  recognized                     :boolean          default(FALSE), not null
#  slug                           :string
#  translations_path              :string
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  installation_id                :string
#  remote_repository_id           :string
#
# Indexes
#
#  index_projects_on_slug  (slug) UNIQUE
#
class Project < ApplicationRecord
  include Syncable
  include LazyHasOne

  encrypts :github_access_token

  has_many :invitations, class_name: "ProjectInvitation", dependent: :delete_all
  has_many :memberships, dependent: :delete_all
  has_many :users, through: :memberships

  has_many :branches, dependent: :delete_all
  has_one :default_branch, ->(x) { where(name: x.default_branch_name) }, class_name: "Branch"
  lazy_has_one :default_branch

  has_many :translations, dependent: :delete_all
  has_many :proposals, dependent: :delete_all
  has_many :pull_requests, dependent: :delete_all
  has_many :commit_tasks, dependent: :delete_all

  validates :remote_repository_id, presence: true
  validates :slug, uniqueness: true, presence: true

  broadcasts_refreshes

  def to_param
    slug
  end

  # START: cosmetic defaults
  # We could get rid of this
  def name
    super.presence || remote_repository_id
  end

  def default_locale
    super.presence || "en"
  end

  # probably we should validate the presence of translations_path
  def translations_path
    super.presence || "config/locales"
  end

  def client
    @client ||= ProjectClient.new(self)
  end

  def url
    File.join(Babelfu.config.github_domain, remote_repository_id)
  end

  def enqueue_sync_data!
    sync_in_progress!
    SyncProjectJob.perform_later(self)
  end
end
