source 'http://rubygems.org'

gem 'rails', '3.1.2'
gem 'pg'
gem 'jquery-rails'
gem 'bcrypt-ruby', :require => 'bcrypt'
gem 'kaminari'
gem 'stalker'
gem 'capistrano'
gem 'paperclip'
gem 'god', :require => false
gem 'juggernaut', '2.0.4'
gem 'rake', '0.9.2'
gem 'rack', '1.3.5'
gem 'oily_png'
gem 'redcarpet', '~> 2.0.0b5'
gem 'coderay', '~> 1.0.4'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "  ~> 3.1.5"
  gem 'coffee-rails', "~> 3.1.1"
  gem 'uglifier'
  gem 'zurb-foundation', "~> 2.1.0"
end

group :production do
  gem 'unicorn', '4.1.1'
  gem 'raindrops', '0.8.0'
  gem "therubyracer"
end

group :development, :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem 'jasminerice'
  gem 'cucumber-rails', '1.0.2'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'factory_girl_rails'
  gem 'annotate', '2.4.0'
  gem 'capybara-webkit', '0.7.0'
  gem 'foreman'
  gem 'thin'
end
