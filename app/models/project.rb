# frozen_string_literal: true

# == Schema Information
#
# Table name: projects
#
#  id                             :bigint           not null, primary key
#  allow_remote_contributors      :boolean          default(FALSE), not null
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

  encrypts :github_access_token

  has_one :metadata, class_name: "MetadataProject", dependent: :delete
  lazy_has_one :metadata

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

  before_validation :set_slug, on: :create

  broadcasts_refreshes

  def installation_remote_repository_id
    [installation_id, remote_repository_id].join(":")
  end

  def installation_remote_repository_id=(value)
    self.installation_id, self.remote_repository_id = value.split(":")
  end

  def to_param
    slug
  end

  def set_slug
    self.slug ||= Random.uuid
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
    @client ||= ProjectGithubClientProxy.new(self, authentication)
  end

  def authentication
    @authentication ||= if installation_id
                          InstallationGithubAuthentication.new(self)
                        else
                          UserGithubAuthentication.new(users.first)
                        end
  end

  def stats
    @stats ||= ProjectStats.new(self)
  end

  def url
    File.join(Babelfu.config.github_domain, remote_repository_id)
  end

  def enqueue_sync_data!
    sync_in_progress!
    SyncProjectJob.perform_later(self)
  end

  def collaborator?(user)
    metadata.github_collaborators.any? { |c| c["login"] == user.github_username && c.dig("permissions", "push") }
  end
end
