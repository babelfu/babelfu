# frozen_string_literal: true

class Schema < ActiveRecord::Migration[7.1]
  def change
    create_table "branches", force: :cascade do |t|
      t.bigint "project_id", null: false
      t.string "name"
      t.string "ref"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "sync_status", default: "not_synced"
      t.datetime "synced_at"
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

    create_table "metadata_users", force: :cascade do |t|
      t.bigint "user_id", null: false
      t.json "github_repositories"
      t.json "github_installations"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.json "github_user"
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
      t.string "sync_status", default: "not_synced"
      t.datetime "synced_at"
      t.string "installation_id"
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
      t.string "sync_status"
      t.datetime "synced_at"
      t.index ["project_id"], name: "index_pull_requests_on_project_id"
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
      t.string "github_remote_id"
      t.json "github_repositories"
      t.string "github_refresh_token"
      t.integer "github_refresh_token_expires_in"
      t.boolean "admin", default: false
      t.index ["email"], name: "index_users_on_email", unique: true
      t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    end

    add_foreign_key "branches", "projects"
    add_foreign_key "commit_tasks", "projects"
    add_foreign_key "memberships", "projects"
    add_foreign_key "memberships", "users"
    add_foreign_key "metadata_users", "users"
    add_foreign_key "project_invitations", "projects"
    add_foreign_key "proposals", "projects"
    add_foreign_key "pull_requests", "projects"
    add_foreign_key "translations", "projects"
  end
end
