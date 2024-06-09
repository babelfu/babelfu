# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_06_09_133029) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "branches", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "name"
    t.string "ref"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "project_id"], name: "index_branches_on_name_and_project_id", unique: true
    t.index ["project_id"], name: "index_branches_on_project_id"
  end

  create_table "commit_tasks", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "branch_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ref"
    t.datetime "commited_at"
    t.string "pull_request_remote_id"
    t.index ["project_id"], name: "index_commit_tasks_on_project_id"
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.jsonb "serialized_properties"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_discard"
    t.text "callback_queue_name"
    t.integer "callback_priority"
    t.datetime "enqueued_at"
    t.datetime "discarded_at"
    t.datetime "finished_at"
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id", null: false
    t.text "job_class"
    t.text "queue_name"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.text "error"
    t.integer "error_event", limit: 2
    t.text "error_backtrace", array: true
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "key"
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.uuid "batch_id"
    t.uuid "batch_callback_id"
    t.boolean "is_discrete"
    t.integer "executions_count"
    t.text "job_class"
    t.integer "error_event", limit: 2
    t.text "labels", array: true
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "project_id", null: false
    t.boolean "admin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_memberships_on_project_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "metadata_projects", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.json "github_collaborators", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_metadata_projects_on_project_id"
  end

  create_table "metadata_users", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.json "github_repositories", default: {}, null: false
    t.json "github_installations", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "github_user", default: {}, null: false
    t.index ["user_id"], name: "index_metadata_users_on_user_id"
  end

  create_table "project_invitations", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "email"
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "token"
    t.index ["project_id"], name: "index_project_invitations_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.string "remote_repository_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "default_locale"
    t.string "translations_path"
    t.string "default_branch_name"
    t.string "installation_id"
    t.string "github_access_token"
    t.datetime "github_access_token_expires_at"
    t.string "slug"
    t.boolean "public", default: false
    t.boolean "recognized", default: false, null: false
    t.boolean "allow_remote_contributors", default: false, null: false
    t.index ["slug"], name: "index_projects_on_slug", unique: true
  end

  create_table "proposals", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "branch_name"
    t.string "key"
    t.string "locale"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_proposals_on_project_id"
  end

  create_table "pull_requests", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "title"
    t.string "url"
    t.string "remote_id"
    t.string "head_branch_name"
    t.string "base_branch_name"
    t.string "repository_id"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_pull_requests_on_project_id"
  end

  create_table "sync_states", force: :cascade do |t|
    t.string "syncable_type", null: false
    t.bigint "syncable_id", null: false
    t.string "status", default: "not_synced", null: false
    t.string "ref_before_sync"
    t.string "ref_after_sync"
    t.datetime "synced_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["syncable_type", "syncable_id"], name: "index_sync_states_on_syncable", unique: true
  end

  create_table "translations", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "locale"
    t.string "key"
    t.string "value"
    t.string "branch_name"
    t.string "file_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "branch_ref"
    t.index ["project_id", "key", "locale", "branch_ref"], name: "idx_on_project_id_key_locale_branch_ref_c865b90c88", unique: true
    t.index ["project_id"], name: "index_translations_on_project_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "github_access_token"
    t.string "github_refresh_token"
    t.boolean "admin", default: false
    t.datetime "github_access_token_expires_at"
    t.datetime "github_refresh_token_expires_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "branches", "projects"
  add_foreign_key "commit_tasks", "projects"
  add_foreign_key "memberships", "projects"
  add_foreign_key "memberships", "users"
  add_foreign_key "metadata_projects", "projects"
  add_foreign_key "metadata_users", "users"
  add_foreign_key "project_invitations", "projects"
  add_foreign_key "proposals", "projects"
  add_foreign_key "pull_requests", "projects"
  add_foreign_key "translations", "projects"
end
