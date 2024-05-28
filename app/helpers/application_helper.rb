# frozen_string_literal: true

module ApplicationHelper
  MAPPING = {
    "notice" => "success",
    "error" => "warning"
  }.freeze

  def map_bootstrap(kind)
    MAPPING[kind] || "primary"
  end

  def connect_to_github_message
    "Don't see your repository? Check the #{link_to 'connections', connections_path}.".html_safe
  end
end
