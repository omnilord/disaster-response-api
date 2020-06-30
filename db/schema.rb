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

ActiveRecord::Schema.define(version: 2020_06_30_023145) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "answers", force: :cascade do |t|
    t.bigint "question_id"
    t.bigint "resource_id", null: false
    t.bigint "survey_template_question_id"
    t.text "content"
    t.json "question_config"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_answers_on_created_by_id"
    t.index ["question_id", "resource_id", "created_at"], name: "latest_answer_by_resource_question_idx"
    t.index ["question_id"], name: "index_answers_on_question_id"
    t.index ["resource_id"], name: "index_answers_on_resource_id"
    t.index ["survey_template_question_id"], name: "index_answers_on_survey_template_question_id"
    t.index ["updated_by_id"], name: "index_answers_on_updated_by_id"
  end

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
    t.geography "coords", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}, null: false
    t.decimal "zoom", precision: 3, scale: 1, default: "9.0", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "current_draft_id", null: false
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.index ["created_by_id"], name: "index_pages_on_created_by_id"
    t.index ["current_draft_id"], name: "index_pages_on_current_draft_id"
    t.index ["i18n"], name: "index_pages_on_i18n"
    t.index ["page"], name: "index_pages_on_page", unique: true
    t.index ["updated_by_id"], name: "index_pages_on_updated_by_id"
  end

  create_table "questions", force: :cascade do |t|
    t.text "content", null: false
    t.bigint "current_draft_id", null: false
    t.boolean "active", default: true
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_questions_on_created_by_id"
    t.index ["current_draft_id"], name: "index_questions_on_current_draft_id"
    t.index ["updated_by_id"], name: "index_questions_on_updated_by_id"
  end

  create_table "resource_activations", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "resource_id", null: false
    t.boolean "active", default: true
    t.json "data"
    t.index ["event_id", "resource_id"], name: "unique_activation", unique: true
    t.index ["event_id"], name: "index_resource_activations_on_event_id"
    t.index ["resource_id"], name: "index_resource_activations_on_resource_id"
  end

  create_table "resources", force: :cascade do |t|
    t.text "name", null: false
    t.text "resource_type", null: false
    t.text "address"
    t.text "city"
    t.text "county"
    t.text "state"
    t.text "postal_code"
    t.text "primary_phone"
    t.text "secondary_phone"
    t.text "private_contact"
    t.text "private_email"
    t.text "private_phone"
    t.text "private_notes"
    t.text "notes"
    t.text "latest_data_source"
    t.bigint "current_draft_id", null: false
    t.boolean "active", default: true
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.geography "coords", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.text "country"
    t.index ["created_by_id"], name: "index_resources_on_created_by_id"
    t.index ["current_draft_id"], name: "index_resources_on_current_draft_id"
    t.index ["name"], name: "index_resources_on_name"
    t.index ["resource_type"], name: "index_resources_on_resource_type", using: :hash
    t.index ["updated_by_id"], name: "index_resources_on_updated_by_id"
  end

  create_table "survey_template_questions", force: :cascade do |t|
    t.bigint "survey_template_id", null: false
    t.bigint "question_id", null: false
    t.integer "position", default: 0, null: false
    t.boolean "active", default: true
    t.boolean "required", default: false
    t.boolean "private", default: false
    t.index ["question_id"], name: "index_survey_template_questions_on_question_id"
    t.index ["survey_template_id", "question_id"], name: "survey_template_question_ids_unique_idx", unique: true
    t.index ["survey_template_id"], name: "index_survey_template_questions_on_survey_template_id"
  end

  create_table "survey_templates", force: :cascade do |t|
    t.text "resource_type", default: "shelter", null: false
    t.bigint "current_draft_id", null: false
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_survey_templates_on_created_by_id"
    t.index ["current_draft_id"], name: "index_survey_templates_on_current_draft_id"
    t.index ["resource_type"], name: "index_survey_templates_on_resource_type", unique: true
    t.index ["updated_by_id"], name: "index_survey_templates_on_updated_by_id"
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
    t.boolean "trusted", default: false
    t.index ["deleted"], name: "index_users_on_deleted"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "answers", "questions", on_delete: :nullify
  add_foreign_key "answers", "resources", on_delete: :cascade
  add_foreign_key "answers", "survey_template_questions", on_delete: :nullify
  add_foreign_key "answers", "users", column: "created_by_id"
  add_foreign_key "answers", "users", column: "updated_by_id"
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
  add_foreign_key "pages", "users", column: "created_by_id"
  add_foreign_key "pages", "users", column: "updated_by_id"
  add_foreign_key "questions", "drafts", column: "current_draft_id"
  add_foreign_key "questions", "users", column: "created_by_id"
  add_foreign_key "questions", "users", column: "updated_by_id"
  add_foreign_key "resources", "drafts", column: "current_draft_id"
  add_foreign_key "resources", "users", column: "created_by_id"
  add_foreign_key "resources", "users", column: "updated_by_id"
  add_foreign_key "survey_template_questions", "questions"
  add_foreign_key "survey_template_questions", "survey_templates"
  add_foreign_key "survey_templates", "drafts", column: "current_draft_id"
  add_foreign_key "survey_templates", "users", column: "created_by_id"
  add_foreign_key "survey_templates", "users", column: "updated_by_id"
end
