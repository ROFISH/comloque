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

ActiveRecord::Schema.define(version: 20150123093809) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assets", force: :cascade do |t|
    t.string   "key",          limit: 255
    t.string   "attachment",   limit: 255
    t.string   "content_type", limit: 255
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "theme_id"
    t.string   "digest",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "permalink",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "forums", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "permalink",            limit: 255
    t.integer  "category_id"
    t.string   "category_permalink",   limit: 255
    t.string   "privacy",                          default: "public", null: false
    t.boolean  "allow_create_topic",               default: true,     null: false
    t.boolean  "allow_create_message",             default: true,     null: false
  end

  create_table "messages", force: :cascade do |t|
    t.string   "topic_id",   limit: 255
    t.text     "body"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permalinks", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "thang_id"
    t.string   "thang_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "scope_id"
  end

  create_table "templates", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.text     "source"
    t.integer  "theme_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "themes", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topics", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "forum_id"
    t.integer  "user_id"
    t.string   "permalink",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "email",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "superuser"
  end

end
