# frozen_string_literal: true

class TranslationsPresenter
  attr_reader :project, :options

  def initialize(project, options = {})
    @project = project
    @options = options.symbolize_keys
  end

  def keys
    @keys ||= pagination.pluck(:key)
  end

  def pagination
    @pagination ||= begin
      pagination = scope.select("translations.key").distinct
      pagination = pagination.where("translations.key ilike ?", "%#{filter_key}%") if filter_key.present?
      if with_proposals
        pagination = pagination.joins("inner JOIN proposals ON translations.key = proposals.key AND translations.locale = proposals.locale AND translations.branch_name = proposals.branch_name AND proposals.value != translations.value").where(proposals: { branch_name: branch_name }).where.not(proposals: { value: nil })
      end

      if with_changes
        pagination = pagination.joins("inner JOIN translations as base_translations ON translations.value != base_translations.value AND translations.key = base_translations.key AND translations.locale = base_translations.locale").
                     where("base_translations.branch_name = ? and base_translations.branch_ref = ?", base_branch_name, base_branch_ref)

      end
      pagination.page(page)
    end
  end

  def locales
    @locales ||= if filter_locales.present?
                   locales_base_query.where(locale: filter_locales).pluck(:locale)
                 else
                   available_locales
                 end
  end

  def selected_locales
    @selected_locales ||= filter_locales || []
  end

  def available_locales
    @available_locales ||= locales_base_query.pluck(:locale)
  end

  def locales_base_query
    scope.select("locale").distinct.order("locale")
  end

  def matrix
    @matrix ||= locales.each_with_object({}) do |locale, hash|
      hash[locale] ||= {}
      keys.each do |key|
        data = { "value" => translation_for(key:, locale:), "proposal" => proposal_for(key:, locale:) }
        data["base"] = base_translation_for(key:, locale:) if base_branch_name != branch_name
        hash[locale][key] = data
      end
    end
  end

  def base_translation_for(key:, locale:)
    base_translations.find { |translation| translation.key == key && translation.locale == locale }&.value
  end

  def base_translations
    @base_translations ||= @project.translations.where(branch_name: base_branch_name, key: keys, locale: locales)
  end

  def translation_for(key:, locale:)
    translations.find { |translation| translation.key == key && translation.locale == locale }&.value
  end

  def translations
    @translations ||= scope.where(key: keys, locale: locales)
  end

  def proposal_for(key:, locale:)
    proposals.find { |proposal| proposal.key == key && proposal.locale == locale }&.value
  end

  def proposals
    @proposals ||= project.proposals.where(branch_name:, key: keys, locale: locales)
  end

  def scope
    project.translations.where(branch_name:, branch_ref:)
  end

  def base_branch_name
    options[:base_branch_name] || "master"
  end

  def base_branch_ref
    @base_branch_ref ||= project.branches.find_by(name: base_branch_name)&.ref
  end

  def branch_name
    options[:branch_name] || project.default_branch_name
  end

  def branch
    @branch ||= project.branches.find_by(name: branch_name)
  end

  def branch_ref
    @branch_ref ||= branch&.ref
  end

  def filter_locales
    options[:filter_locales]
  end

  def page
    options[:page] || 1
  end

  def filter_key
    options[:filter_key]
  end

  def with_changes
    ActiveModel::Type::Boolean.new.cast(options[:with_changes])
  end

  def with_proposals
    ActiveModel::Type::Boolean.new.cast(options[:with_proposals])
  end
end
