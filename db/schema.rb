# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150608030535) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assets", force: :cascade do |t|
    t.string   "key"
    t.string   "attachment"
    t.string   "content_type"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "theme_id"
    t.string   "digest"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.string   "permalink"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "emojis", force: :cascade do |t|
    t.string   "name"
    t.string   "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "forum_reads", force: :cascade do |t|
    t.integer  "forum_id"
    t.integer  "user_id"
    t.datetime "updated_at"
  end

  create_table "forums", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "permalink"
    t.integer  "category_id"
    t.string   "category_permalink"
    t.string   "privacy",              default: "public", null: false
    t.boolean  "allow_create_topic",   default: true,     null: false
    t.boolean  "allow_create_message", default: true,     null: false
    t.datetime "last_posted_at"
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "topic_id"
    t.text     "body"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "moderatorships", force: :cascade do |t|
    t.integer  "forum_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "permalinks", force: :cascade do |t|
    t.string   "name"
    t.integer  "thang_id"
    t.string   "thang_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "scope_id"
  end

  create_table "private_topic_users", force: :cascade do |t|
    t.integer  "topic_id",     null: false
    t.integer  "user_id",      null: false
    t.datetime "last_read",    null: false
    t.datetime "last_message", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "reports", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "mod_id"
    t.datetime "resolved_at"
    t.string   "resolution_actions"
    t.integer  "message_id"
    t.text     "reason"
    t.text     "resolution"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.text     "mod_notes"
  end

  create_table "swear_words", force: :cascade do |t|
    t.string   "word"
    t.boolean  "case_sensitive",          default: false, null: false
    t.string   "mask"
    t.boolean  "require_beginning_space", default: true,  null: false
    t.boolean  "require_ending_space",    default: true,  null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  create_table "templates", force: :cascade do |t|
    t.string   "name"
    t.text     "source"
    t.integer  "theme_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "themes", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topic_reads", force: :cascade do |t|
    t.integer  "topic_id"
    t.integer  "user_id"
    t.datetime "updated_at"
  end

  create_table "topics", force: :cascade do |t|
    t.string   "name"
    t.integer  "forum_id"
    t.integer  "user_id"
    t.string   "permalink"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "messages_count", default: 0, null: false
    t.datetime "last_posted_at"
    t.integer  "views",          default: 0, null: false
    t.datetime "locked_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "superuser"
  end

end
