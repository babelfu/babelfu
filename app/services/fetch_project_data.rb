# frozen_string_literal: true

class FetchProjectData
  attr_reader :project

  def initialize(project)
    @project = project
  end

  def fetch!
    data = client.repository
    config_file = fetch_config_file
    project.config_from_repo = config_file

    if project.use_config_from_repo? && valid_config_file?(config_file)
      project.default_locale = config_file["default_locale"]
      project.translations_path = config_file["translations_path"]
    end

    project.default_branch_name = data.default_branch
    project.repo_public = !data.private
    project.save!

    metadata = project.metadata
    metadata.github_collaborators = client.collaborators.map(&:to_hash) if project.installation_id.present?
    metadata.repository = data.to_hash
    metadata.save!
  end

  private

  def valid_config_file?(config_file)
    config_file["default_locale"].present? && config_file["translations_path"].present?
  end

  def fetch_config_file
    YAML.safe_load(Base64.decode64(client.contents(path: ".babelfu.yml").content))
  rescue Octokit::NotFound
    {}
  end

  def client
    project.client
  end
end
