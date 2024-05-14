# frozen_string_literal: true

# == Schema Information
#
# Table name: projects
#
#  id                   :bigint           not null, primary key
#  default_branch_name  :string
#  default_locale       :string
#  name                 :string
#  sync_status          :string           default("not_synced")
#  synced_at            :datetime
#  translations_path    :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  installation_id      :string
#  remote_repository_id :string
#
class Project < ApplicationRecord
  has_many :invitations, class_name: "ProjectInvitation", dependent: :delete_all
  has_many :memberships, dependent: :delete_all
  has_many :users, through: :memberships

  has_many :branches, dependent: :delete_all
  has_one :default_branch, ->(x) { where(name: x.default_branch_name) }, class_name: "Branch"

  has_many :translations, dependent: :delete_all
  has_many :proposals, dependent: :delete_all
  has_many :pull_requests, dependent: :delete_all
  has_many :commit_tasks, dependent: :delete_all

  validates :remote_repository_id, presence: true

  broadcasts_refreshes

  # START: cosmetic defaults
  # We could get rid of this
  def name
    super.presence || remote_repository_id
  end

  def default_locale
    super.presence || "en"
  end

  def translations_path
    super.presence || "config/locales"
  end

  def client
    @client ||= ProjectClient.new(self)
  end

  def url
    "https://github.com/#{remote_repository_id}"
  end

  def enqueue_sync_data!
    update!(sync_status: "in_progress")
    SyncProjectJob.perform_later(self)
  end

  # Returns the branches that need to be synced based on default repo branch
  # and the head and base branches of the pull requests.
  # It returns the default_branch first.
  def branches_to_sync
    [[default_branch_name] + pull_requests.flat_map { |x| [x.head_branch_name, x.base_branch_name] }].compact.flatten.uniq
  end
end
