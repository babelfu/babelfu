# frozen_string_literal: true

class FetchBranches
  attr_reader :project

  def initialize(project)
    @project = project
  end

  def fetch!
    remote_branches = client.branches

    remote_branches.each do |remote_branch|
      branch = project.branches.find_or_initialize_by(name: remote_branch.name)
      branch.name = remote_branch.name
      branch.save!
    end
  end

  delegate :client, to: :project
end
