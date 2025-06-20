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

ActiveRecord::Schema[8.0].define(version: 2025_06_20_192226) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "classrooms", force: :cascade do |t|
    t.string "name"
    t.bigint "teacher_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["teacher_id"], name: "index_classrooms_on_teacher_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "classroom_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["classroom_id"], name: "index_memberships_on_classroom_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "questions", force: :cascade do |t|
    t.bigint "topic_id", null: false
    t.text "question_text"
    t.integer "correct_answer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["topic_id"], name: "index_questions_on_topic_id"
  end

  create_table "responses", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.integer "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_responses_on_question_id"
  end

  create_table "scores", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "topic_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "correct"
    t.integer "total"
    t.index ["topic_id"], name: "index_scores_on_topic_id"
    t.index ["user_id"], name: "index_scores_on_user_id"
  end

  create_table "topics", force: :cascade do |t|
    t.string "title"
    t.text "intro"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "public"
    t.boolean "requires_auth"
    t.string "category"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "role", default: "0"
    t.integer "parent_id"
    t.boolean "created_by_family"
    t.string "username", default: "", null: false
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "classrooms", "users", column: "teacher_id"
  add_foreign_key "memberships", "classrooms"
  add_foreign_key "memberships", "users"
  add_foreign_key "questions", "topics"
  add_foreign_key "responses", "questions"
  add_foreign_key "scores", "topics"
  add_foreign_key "scores", "users"
end
