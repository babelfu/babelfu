# frozen_string_literal: true

class UpsertTranslations
  class << self
    def call(project, translations)
      translations = translations.map! do |translation|
        translation.merge(branch_refs: [translation.delete(:branch_ref)])
      end
      project.translations.upsert_all(translations,
                                      unique_by: [:project_id, :key, :locale, :value],
                                      on_duplicate: Arel.sql("branch_refs = array_append(translations.branch_refs, EXCLUDED.branch_refs[1])"))
    end
  end
end
