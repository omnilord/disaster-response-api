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

ActiveRecord::Schema.define(version: 2018_09_30_075741) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "pages", force: :cascade do |t|
    t.text "i18n", default: "en"
    t.text "page"
    t.text "title"
    t.text "content"
    t.integer "editor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  add_foreign_key "pages", "users", column: "editor_id", on_update: :cascade, on_delete: :nullify
end
