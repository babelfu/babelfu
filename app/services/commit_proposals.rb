# frozen_string_literal: true

# TODO: move to private method the methods that are not used outside the class
class CommitProposals
  attr_reader :project, :head_branch_name, :base_branch_name

  def initialize(project, head_branch_name, base_branch_name = nil)
    @project = project
    @head_branch_name = head_branch_name
    @base_branch_name = base_branch_name
  end

  def commit!
    tree_content = []
    files_with_content.each do |file_path, content|
      sha = client.create_blob(Base64.encode64(content), "base64")
      tree_content << { path: file_path, mode: "100644", type: "blob", sha: }
    end

    new_tree = client.create_tree(tree_content, base_tree: head_branch_ref)
    commit = client.create_commit("update translations", new_tree.sha, head_branch_ref)
    client.update_ref("heads/#{head_branch_name}", commit.sha)
  end

  def proposals
    @proposals ||= project.proposals.where(branch_name: head_branch_name)
  end

  private

  delegate :client, to: :project

  def head_branch_ref
    head_branch&.ref
  end

  def head_branch
    @head_branch ||= project.branches.find_by(name: head_branch_name)
  end

  def files_with_content
    proposal_files.index_with do |file_path|
      generate_content(file_path, data_for_file_path(file_path))
    end
  end

  def proposal_files
    proposals.map(&:file_path).uniq
  end

  def generate_content(file_path, data)
    # generate the content of the file with the translations
    # it should be able to generate json, yaml, etc
    # depending on the file extension.
    #
    # This is a naive implementation that only supports I18n rails like systems
    case File.extname(file_path)
    when ".json"
      JSON.pretty_generate(data)
    when ".yml", ".yaml"
      data.to_yaml
    else
      raise "Unsupported file extension"
    end
  end

  def data_for_file_path(file_path)
    # generate the flat hash of translations from the existing translations
    # including the locale in the key
    translations = project.translations.where(file_path:, branch_name: head_branch_name)
    content = translations.each_with_object({}) do |translation, hash|
      hash["#{translation.locale}.#{translation.key}"] = translation.value
    end

    # apply the proposals on top of the existing translations
    proposals.select { |proposal| proposal.file_path == file_path }.each do |proposal|
      content["#{proposal.locale}.#{proposal.key}"] = proposal.value
    end

    # convert the flat hash to a nested hash
    # it works for json and yaml I18n rails like systems
    deep_key = {}
    content.each_pair do |key, value|
      deep_key_tmp = key.split(".").reverse.inject(value) { |assigned_value, k| { k => assigned_value } }
      deep_key.deep_merge!(deep_key_tmp)
    end
    deep_key
  end
end
