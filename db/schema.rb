# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_12_07_000500) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "drafts", force: :cascade do |t|
    t.string "draftable_type"
    t.bigint "draftable_id"
    t.jsonb "data"
    t.bigint "user_id"
    t.bigint "approved_by_id"
    t.datetime "approved_at"
    t.bigint "denied_by_id"
    t.datetime "denied_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approved_by_id"], name: "index_drafts_on_approved_by_id"
    t.index ["denied_by_id"], name: "index_drafts_on_denied_by_id"
    t.index ["draftable_type", "draftable_id"], name: "index_drafts_on_draftable_type_and_draftable_id"
    t.index ["user_id"], name: "index_drafts_on_user_id"
  end

  create_table "event_managers", force: :cascade do |t|
    t.bigint "event_id"
    t.bigint "user_id"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_event_managers_on_event_id"
    t.index ["user_id"], name: "index_event_managers_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.text "slug", null: false
    t.text "name"
    t.text "disaster_type"
    t.text "content"
    t.datetime "activated"
    t.datetime "deactivated"
    t.bigint "administrator_id"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.bigint "current_draft_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["administrator_id"], name: "index_events_on_administrator_id"
    t.index ["created_by_id"], name: "index_events_on_created_by_id"
    t.index ["current_draft_id"], name: "index_events_on_current_draft_id"
    t.index ["updated_by_id"], name: "index_events_on_updated_by_id"
  end

  create_table "pages", force: :cascade do |t|
    t.text "i18n", default: "en"
    t.text "page"
    t.text "title"
    t.text "content"
    t.integer "editor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "current_draft_id", null: false
    t.index ["current_draft_id"], name: "index_pages_on_current_draft_id"
    t.index ["editor_id"], name: "index_pages_on_editor_id"
    t.index ["i18n"], name: "index_pages_on_i18n"
    t.index ["page"], name: "index_pages_on_page", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.text "email", default: "", null: false
    t.text "encrypted_password", default: "", null: false
    t.text "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.boolean "admin", default: false
    t.text "real_name"
    t.text "location"
    t.text "i18n", default: "en"
    t.text "time_zone"
    t.boolean "deleted", default: false, null: false
    t.integer "deleted_by"
    t.text "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted"], name: "index_users_on_deleted"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "drafts", "users"
  add_foreign_key "drafts", "users", column: "approved_by_id"
  add_foreign_key "drafts", "users", column: "denied_by_id"
  add_foreign_key "event_managers", "events"
  add_foreign_key "event_managers", "users"
  add_foreign_key "events", "drafts", column: "current_draft_id"
  add_foreign_key "events", "users", column: "administrator_id"
  add_foreign_key "events", "users", column: "created_by_id"
  add_foreign_key "events", "users", column: "updated_by_id"
  add_foreign_key "pages", "drafts", column: "current_draft_id"
  add_foreign_key "pages", "users", column: "editor_id", on_update: :cascade, on_delete: :nullify
end
