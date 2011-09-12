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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110720123751) do

  create_table "authentications", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "game_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "games", :force => true do |t|
    t.text     "sgf"
    t.string   "name"
    t.integer  "mode",              :default => 0
    t.integer  "current_player_id"
    t.integer  "status",            :default => 0
    t.integer  "black_player_id"
    t.integer  "white_player_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "access",            :default => 3
    t.integer  "score_requester",   :default => 0
  end

  create_table "notifications", :force => true do |t|
    t.integer  "user_id"
    t.integer  "game_id"
    t.datetime "send_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "encrypted_password"
    t.string   "rank",                 :default => "0"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "wins",                 :default => 0
    t.integer  "loses",                :default => 0
    t.integer  "points",               :default => 0
    t.boolean  "open_for_play",        :default => true
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.datetime "last_request_at"
    t.integer  "role",                 :default => 0
    t.boolean  "email_confirmed",      :default => false
    t.boolean  "notify_pendding_move", :default => false
    t.integer  "connected",            :default => 0
  end

end
