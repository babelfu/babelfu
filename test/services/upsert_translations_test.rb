require "test_helper"

class UpserTranslationsTest < ActiveSupport::TestCase
  test "creates the translation" do
    project = projects(:one)
    project.translations.delete_all
    assert_equal 0, project.translations.count

    translations = [
      { key: "hello", locale: "en", value: "Hello", branch_ref: "aaa", file_path: "test" }
    ]
    UpsertTranslations.call(project, translations)
    assert_equal 1, project.translations.count

    translation = project.translations.reload.last
    assert_equal "Hello", translation.value
    assert_equal ["aaa"], translation.branch_refs
  end

  test "different values" do
    project = projects(:one)
    project.translations.delete_all
    assert_equal 0, project.translations.count

    translations = [
      { key: "hello", locale: "en", value: "Hello", branch_ref: "aaa" }
    ]
    UpsertTranslations.call(project, translations)

    translations = [
      { key: "hello", locale: "en", value: "Hello 2", branch_ref: "bbb" }
    ]
    UpsertTranslations.call(project, translations)

    assert_equal 2, project.translations.count
    translation = project.translations.reload.last
    assert_equal "Hello 2", translation.value
    assert_equal ["bbb"], translation.branch_refs
  end

  test "same value different branch_ref" do
    project = projects(:one)
    project.translations.delete_all
    assert_equal 0, project.translations.count

    translations = [
      { key: "hello", locale: "en", value: "Hello", branch_ref: "aaa" }
    ]
    UpsertTranslations.call(project, translations)

    translations = [
      { key: "hello", locale: "en", value: "Hello", branch_ref: "bbb" }
    ]
    UpsertTranslations.call(project, translations)

    assert_equal 1, project.translations.count
    translation = project.translations.reload.last
    assert_equal "Hello", translation.value
    assert_equal ["aaa", "bbb"], translation.branch_refs
  end
end
