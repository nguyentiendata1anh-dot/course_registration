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

ActiveRecord::Schema[8.1].define(version: 2025_12_04_120300) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "courses", force: :cascade do |t|
    t.integer "capacity"
    t.string "code"
    t.datetime "created_at", null: false
    t.integer "credits"
    t.integer "day_of_week"
    t.datetime "deadline"
    t.text "description"
    t.date "end_date"
    t.time "end_time"
    t.string "name"
    t.text "prerequisite"
    t.string "room"
    t.string "schedule"
    t.date "start_date"
    t.time "start_time"
    t.string "teacher_name"
    t.integer "term_id"
    t.datetime "updated_at", null: false
    t.index ["end_date"], name: "index_courses_on_end_date"
    t.index ["start_date"], name: "index_courses_on_start_date"
    t.index ["term_id"], name: "index_courses_on_term_id"
  end

  create_table "enrollments", force: :cascade do |t|
    t.float "attendance_score"
    t.integer "course_id", null: false
    t.datetime "created_at", null: false
    t.float "final_exam_score"
    t.float "final_score"
    t.float "midterm_exam_score"
    t.float "midterm_score"
    t.integer "section_id"
    t.float "total_score"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["course_id"], name: "index_enrollments_on_course_id"
    t.index ["section_id"], name: "index_enrollments_on_section_id"
    t.index ["user_id"], name: "index_enrollments_on_user_id"
  end

  create_table "profile_requests", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.date "dob"
    t.string "full_name"
    t.string "phone"
    t.text "reason"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_profile_requests_on_user_id"
  end

  create_table "reminders", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "sections", force: :cascade do |t|
    t.integer "capacity"
    t.string "code"
    t.integer "course_id", null: false
    t.datetime "created_at", null: false
    t.date "end_date"
    t.string "room"
    t.string "schedule"
    t.date "start_date"
    t.string "teacher_name"
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_sections_on_course_id"
  end

  create_table "terms", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "end_date"
    t.string "name", null: false
    t.date "start_date"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.date "dob"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "full_name"
    t.string "major"
    t.string "phone"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role"
    t.string "student_id"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["student_id"], name: "index_users_on_student_id", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "courses", "terms"
  add_foreign_key "enrollments", "courses"
  add_foreign_key "enrollments", "sections"
  add_foreign_key "enrollments", "users"
  add_foreign_key "profile_requests", "users"
  add_foreign_key "sections", "courses"
end
