# frozen_string_literal: true

class GithubLinkComponent < ViewComponent::Base
  attr_reader :url

  def initialize(url)
    @url = url
  end
end
