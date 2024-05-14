# frozen_string_literal: true

class FetchBranchTranslations
  attr_reader :project, :branch_name

  def initialize(project, branch_name:)
    @project = project
    @branch_name = branch_name
  end

  def fetch!
    # TODO: this should be under a mutex
    # TODO: could use this endpoint
    # https://docs.github.com/en/rest/commits/commits?apiVersion=2022-11-28#compare-two-commits
    # to get the diff between two commits and only fetch the files that changed

    # Get the remote branch
    remote_branch = client.branch(branch_name)

    # Get the local branch
    branch = project.branches.find_or_initialize_by(name: branch_name)
    branch_ref = remote_branch.commit.sha

    # exist if the branch is already fetched
    return if branch.ref == branch_ref

    # Fetch and save translations for the branch and ref
    fetch_ref_translations = FetchRefTranslations.new(project, remote_branch.commit.sha)

    fetch_ref_translations.source_files.each do |source_file|
      data = fetch_ref_translations.get_data_from_source_file(source_file)
      translations = flatten_hash(data).map do |full_key, value|
        data = {}
        locale, key = full_key.split(".", 2)
        file_path = File.join(translations_path, source_file.path)

        { key:, value:, branch_name:, branch_ref:, file_path:, locale: }
      end

      project.translations.upsert_all(translations)
    end

    # Update the branch ref
    branch.ref = branch_ref
    branch.save!

    # Delete translations of previous refs
    project.translations.where(branch_name:).where.not(branch_ref: branch.ref).delete_all
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

  delegate :client, to: :project

  def translations_path
    project.translations_path&.split("/")&.join("/") || ""
  end

  class FetchRefTranslations
    attr_reader :project, :ref

    def initialize(project, ref)
      @project = project
      @ref = ref
    end

    def source_files
      base_path = translations_path.split("/")[0..-2].join("/")
      sha_base = client.contents(path: base_path, ref:).find do |x|
                   x.path == translations_path
                 end&.sha
      return [] unless sha_base

      client.tree(sha_base, recursive: true)[:tree].select { |x| (x.type == "blob" && (x.path.ends_with?(".yml") || x.path.ends_with?(".yaml"))) || x.path.ends_with?(".json") }
    end

    def get_data_from_source_file(source_file)
      content = get_source_file_content(source_file)
      return {} unless content

      YAML.load(content)
    rescue Psych::SyntaxError
      {}
    end

    def get_source_file_content(source_file)
      puts source_file.sha
      blob = client.blob(source_file.sha)
      if blob.encoding == "base64"
        Base64.decode64(blob.content)
      else
        blob.content
      end
    end

    private

    def client
      project.client
    end

    def translations_path
      project.translations_path&.split("/")&.join("/") || ""
    end
  end
end
