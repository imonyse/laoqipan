# simply run rake jammit:package to compile your coffeescript and then package up all your assets
# including the newly compiled javascripts

namespace :jammit do
  task :package do
    Rake::Task["barista:brew"].invoke
    Jammit.package!
  end
end