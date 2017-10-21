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

ActiveRecord::Schema.define(version: 20170801200013) do

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "auth_token"
    t.index ["auth_token"], name: "index_users_on_auth_token", unique: true
  end

  create_table "word_collections", force: :cascade do |t|
    t.string   "name"
    t.boolean  "public"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_word_collections_on_user_id"
  end

  create_table "words", force: :cascade do |t|
    t.string   "definition"
    t.string   "translation"
    t.integer  "word_collection_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["word_collection_id"], name: "index_words_on_word_collection_id"
  end

end
