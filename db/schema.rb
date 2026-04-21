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

ActiveRecord::Schema[8.0].define(version: 2026_04_21_164710) do
  create_table "participants", force: :cascade do |t|
    t.integer "poll_id", null: false
    t.string "name", null: false
    t.string "cookie_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["poll_id", "cookie_id"], name: "index_participants_on_poll_id_and_cookie_id", unique: true
    t.index ["poll_id"], name: "index_participants_on_poll_id"
  end

  create_table "polls", force: :cascade do |t|
    t.string "token"
    t.string "title"
    t.string "creator_cookie_id"
    t.string "creator_name"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_polls_on_expires_at"
    t.index ["token"], name: "index_polls_on_token", unique: true
  end

  create_table "responses", force: :cascade do |t|
    t.integer "participant_id", null: false
    t.integer "time_slot_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["participant_id", "time_slot_id"], name: "index_responses_on_participant_id_and_time_slot_id", unique: true
    t.index ["participant_id"], name: "index_responses_on_participant_id"
    t.index ["time_slot_id"], name: "index_responses_on_time_slot_id"
  end

  create_table "time_slots", force: :cascade do |t|
    t.integer "poll_id", null: false
    t.date "date", null: false
    t.integer "starts_at_minute", null: false
    t.integer "ends_at_minute", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["poll_id", "date", "starts_at_minute", "ends_at_minute"], name: "index_time_slots_on_poll_date_window", unique: true
    t.index ["poll_id", "date"], name: "index_time_slots_on_poll_id_and_date"
    t.index ["poll_id", "starts_at_minute", "ends_at_minute"], name: "idx_on_poll_id_starts_at_minute_ends_at_minute_cd119c0487"
    t.index ["poll_id"], name: "index_time_slots_on_poll_id"
  end

  add_foreign_key "participants", "polls"
  add_foreign_key "responses", "participants"
  add_foreign_key "responses", "time_slots"
  add_foreign_key "time_slots", "polls"
end
