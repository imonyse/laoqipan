#!/usr/bin/env ruby

def usage
  puts "usage: worker test|development|production"
  exit
end

if ARGV.length != 1
  usage
end

if !["test", "development", "production"].include? ARGV[0]
  usage
end

env_arg = ARGV[0]

RAILS_ENV = ENV.fetch("RAILS_ENV", env_arg)
RAILS_ROOT = File.expand_path("../..", __FILE__)

ENV['BUNDLE_GEMFILE'] = "#{RAILS_ROOT}/Gemfile"
require 'bundler'
Bundler.setup(:default, RAILS_ENV.to_sym)

require 'pg'
require 'juggernaut'

pg_config = Hash[YAML.load_file("#{RAILS_ROOT}/config/database.yml")[RAILS_ENV].map { |k,v| [k.to_sym, v]}]
pg_options = {
  :host => 'localhost',
  :dbname => pg_config[:database],
  :user => pg_config[:username],
  :password => pg_config[:password]
}

Juggernaut.subscribe do |event, data|
  user_id = data['meta']
  next unless user_id

  count = 0
  case event
  when :subscribe
    count = 1
  when :unsubscribe
    count = -1
  end
  # should do a reference count based connection display
  pg_conn = PGconn.connect(pg_options)
  
  if count == 1
    pg_conn.exec("update users set connected = connected + 1 where id='#{user_id}'")
    ref = pg_conn.exec("select connected from users where id = '#{user_id}'")
    Juggernaut.publish("users", {"who" => "#{user_id}"}.merge(ref[0]))
    ref.clear()
  elsif count == -1
    pg_conn.exec("update users set connected = connected - 1 where id='#{user_id}'")
    ref = pg_conn.exec("select connected from users where id = '#{user_id}'")
    Juggernaut.publish("users", {"who" => "#{user_id}"}.merge(ref[0]))
    ref.clear()
  end
  
  pg_conn.close
end