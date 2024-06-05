# frozen_string_literal: true

class ProjectStats
  attr_reader :project, :default_branch

  def initialize(project)
    @project = project
    @default_branch = project.default_branch
  end

  def locales
    @locales ||= @default_branch.translations.pluck(:locale).uniq.map { |locale| LocaleStats.new(self, locale) }.sort_by { |x| [x.percent_translated, x.locale] }.reverse
  end

  def total_percent_translated
    return 0 if total_translations.zero?

    (1 - ((expected_translations - total_translations) / total_translations.to_f)) * 100
  end

  def total_translations
    @total_translations ||= @default_branch.translations.count
  end

  def expected_translations
    locales.count * keys.count
  end

  class LocaleStats
    attr_reader :locale, :stats

    def initialize(stats, locale)
      @stats = stats
      @locale = locale
    end

    def percent_translated
      stats.default_branch.translations.where(locale: locale).pluck(:key).uniq.count / stats.total_keys.to_f * 100
    end
  end

  def total_keys
    @total_keys ||= keys.count
  end

  def keys
    @keys ||= default_branch.translations.pluck(:key).uniq
  end
end
