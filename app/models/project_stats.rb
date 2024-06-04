# frozen_string_literal: true

class ProjectStats
  attr_reader :project, :default_branch

  def initialize(project)
    @project = project
    @default_branch = project.default_branch
  end

  def locales
    @locales ||= @default_branch.translations.pluck(:locale).uniq.map { |locale| LocaleStats.new(self, locale) }
  end

  class LocaleStats
    attr_reader :locale, :stats

    def initialize(stats, locale)
      @stats = stats
      @locale = locale
    end

    def percent_translated
      stats.default_branch.translations.where(locale: locale).pluck(:key).uniq.count / stats.total_keys.to_f
    end
  end

  def total_keys
    @total_keys ||= keys.count
  end

  def keys
    @keys ||= default_branch.translations.pluck(:key).uniq
  end
end
