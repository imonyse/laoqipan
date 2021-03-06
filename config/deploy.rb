set :user, 'webuser'
set :domain, '66.85.155.109'
set :application, "laoqipan"
set :repository,  "#{user}@#{domain}:git/#{application}.git"
set :deploy_to, "/home/webuser/laoqipan"
set :use_sudo, false
set :scm, :git
set :branch, :master
set :normalize_asset_timestamps, false
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, domain                        # Your HTTP server, Apache/etc
role :app, domain                          # This may be the same as your `Web` server
role :db, domain, :primary => true # This is where Rails migrations will run

# $:.unshift(File.expand_path('./lib', ENV['rvm_path']))
# require 'rvm/capistrano'
# 
# set :rvm_ruby_string, '1.9.2'
# set :rvm_type, :user
# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  task :seed do
    run "cd #{current_path}; rake db:seed RAILS_ENV=production"
  end
  task :symlink_extras do
    run "ln -nfs #{shared_path}/config/private.yml #{release_path}/config/private.yml && ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end

after "deploy:update_code", :bundle_install
task :bundle_install, :roles => :app do
  run "cd #{release_path} && ln -s #{shared_path}/bundle #{release_path}/vendor/bundle && bundle install --deployment  --without development:test"
end

before "deploy:restart", :precompile
task :precompile, :roles => :app do
  run "cd #{release_path} && bundle exec rake assets:precompile RAILS_ENV=production"
end

after "deploy:restart", :restart_worker
task :restart_worker, :roles => :app do
  run "god stop laoqipan-worker ; god stop unicorn-worker ; god quit ; sleep 3 ; cd #{release_path} && god -c config/god.rb"
end

after "deploy:update_code", "deploy:symlink_extras"
after "deploy", "deploy:cleanup"