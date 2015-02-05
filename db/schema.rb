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

ActiveRecord::Schema.define(version: 20150205231006) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.text     "description"
  end

  create_table "category_packages", force: :cascade do |t|
    t.integer  "category_id"
    t.integer  "package_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "category_packages", ["category_id"], name: "index_category_packages_on_category_id", using: :btree
  add_index "category_packages", ["package_id"], name: "index_category_packages_on_package_id", using: :btree

  create_table "npm_keywords", force: :cascade do |t|
    t.string   "keyword"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "npm_users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "package_maintainers", id: false, force: :cascade do |t|
    t.integer "package_id"
    t.integer "npm_user_id"
  end

  create_table "package_npm_keywords", id: false, force: :cascade do |t|
    t.integer "package_id"
    t.integer "npm_keyword_id"
  end

  create_table "package_versions", force: :cascade do |t|
    t.integer  "package_id"
    t.string   "version"
    t.datetime "released"
  end

  create_table "packages", force: :cascade do |t|
    t.string   "name"
    t.string   "repository_url"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "latest_version"
    t.string   "description"
    t.string   "license"
    t.integer  "author_id"
    t.datetime "latest_version_date"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer  "has_tests"
    t.integer  "has_readme"
    t.integer  "updated_recently"
    t.integer  "more_than_a_shell"
    t.integer  "substantive_functionality"
    t.text     "review"
    t.integer  "package_version_id",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "password_digest"
    t.string   "auth_token"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

end
