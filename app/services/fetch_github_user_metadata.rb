# frozen_string_literal: true

class FetchGithubUserMetadata
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def fetch!
    metadata = user.metadata || user.build_metadata

    metadata.github_user = client.user.to_hash
    metadata.github_installations = client.find_user_installations.installations.map(&:to_hash)

    repositories = {}
    metadata.github_installations.each do |installation|
      repositories[installation["id"]] =
        client.find_installation_repositories_for_user(installation["id"]).repositories.map(&:to_hash)
    end

    metadata.github_repositories = repositories
    metadata.save!
  end

  delegate :client, to: :user
end
