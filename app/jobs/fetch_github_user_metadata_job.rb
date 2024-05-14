# frozen_string_literal: true

class FetchGithubUserMetadataJob < ApplicationJob
  queue_as :default

  def perform(user)
    FetchGithubUserMetadata.new(user).fetch!
  end
end
