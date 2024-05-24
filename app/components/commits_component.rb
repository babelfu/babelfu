# frozen_string_literal: true

class CommitsComponent < ViewComponent::Base
  include Turbo::StreamsHelper

  attr_reader :presenter, :create_commit_path

  def initialize(presenter:, create_commit_path:)
    @presenter = presenter
    @create_commit_path = create_commit_path
  end
end
