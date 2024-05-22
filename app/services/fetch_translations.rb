# frozen_string_literal: true

class FetchTranslations
  attr_reader :project, :branch_name

  def initialize(project, branch_name)
    @project = project
    @branch_name = branch_name
  end

  def need_sync?
    branch = project.branches.find_or_initialize_by(name: branch_name)

    branch.ref != remote_branch_ref
  end

  def source_files
    sha_base = client.contents(path: base_path, ref: remote_branch_ref).find do |x|
                 x.path == translations_path
               end&.sha

    return [] unless sha_base

    source_files = client.tree(sha_base, recursive: true)[:tree]

    # TODO: extract the filter by file extension and it should ask the project
    source_files.select { |x| (x.type == "blob" && (x.path.ends_with?(".yml") || x.path.ends_with?(".yaml"))) || x.path.ends_with?(".json") }
  end

  def get_translations_from_file_path_ref(file_path, file_path_ref)
    data = get_data_from_source_file_ref(file_path_ref)

    flatten_hash(data).map do |full_key, value|
      data = {}
      locale, key = full_key.split(".", 2)
      full_file_path = File.join(translations_path, file_path)
      { key:, value:, file_path: full_file_path, locale: }
    end
  end

  def remote_branch_ref
    remote_branch.commit.sha
  end

  private

  def get_data_from_source_file_ref(source_file_ref)
    content = get_source_file_content_for_ref(source_file_ref)
    return {} unless content

    YAML.load(content)
  rescue Psych::SyntaxError
    {}
  end

  def get_source_file_content_for_ref(source_file_ref)
    blob = client.blob(source_file_ref)
    if blob.encoding == "base64"
      Base64.decode64(blob.content)
    else
      blob.content
    end
  end

  def base_path
    translations_path.split("/")[0..-2].join("/")
  end

  def translations_path
    project.translations_path&.split("/")&.join("/") || ""
  end

  def remote_branch
    @remote_branch ||= client.branch(branch_name)
  end

  def client
    project.client
  end

  def flatten_hash(hash)
    hash.each_with_object({}) do |(k, v), h|
      if v.is_a? Hash
        flatten_hash(v).map do |h_k, h_v|
          h[:"#{k}.#{h_k}"] = h_v
        end
      else
        h[k] = v
      end
    end.deep_stringify_keys
  end
end
