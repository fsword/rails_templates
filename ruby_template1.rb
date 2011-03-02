require "thor/shell"
say("Modifying a new Rails app ...", :yellow)

#----------------------------------------------------------------------------
# Configure
#----------------------------------------------------------------------------
=begin
unless options[:database] == 'sqlite3'
  username = ask("What's your database username[root]")
  username = 'root' if username.blank?
  password = ask("What's your database password(default is empty)")
end

if yes?('Would you like to use BDD test(Rspec,cucumber...) instead of Test::Unit? (yes/no)')
  bdd_flag = true
else
  bdd_flag = false
end
if yes?('Would you like to use jQuery instead of Prototype? (yes/no)')
  jquery_flag = true
else
  jquery_flag = false
end

if yes?('Would you like to install Devise?')
  devise_flag = true
else
  devise_flag = false
  model_name = ask("What would you like the user model to be called? [user]")
  model_name = "user" if model_name.blank?
end
if yes?('Would you like to use Haml instead of erb? (yes/no)')
  haml_flag = true
else
  haml_flag = false
end

model_name = ask("What would you like the user model to be called? [user]")
model_name = "user" if model_name.blank?
=end
bdd_flag = true
jquery_flag = true
devise_flag = true
haml_flag = false
model_name = "user"
#----------------------------------------------------------------------------
# Set up git
#----------------------------------------------------------------------------
say("setting up source control with 'git'...", :yellow)
# ignore files

=begin
append_file '.gitignore' do
  # specific to Mac OS X
  '.DS_Store'
  # ignore log files
  '/log/*'
  # ignore tmp files
  '/tmp/*'
  # ignore database.yml
  'config/database.yml'
  'db/*.sqlite3'
  'db/schema.rb'
  '**/.DS_Store'
  'vendor/cache/*'
  '*.rbc'
  '*.sassc'
  '.sass-cache'
  'capybara-*.html'
  '.rspec'
  '.bundle'
  '/vendor/bundle'
  '/public/system/*'
  '/coverage/'
  '/spec/tmp/*'
  '**.orig'
  'rerun.txt'
end
=end
#FIXME code not work, temp fix
run 'rm .gitignore'
get "https://gist.github.com/822048.txt", ".gitignore"
# to remain log/ tmp/ in git
run 'touch log/.gitignore tmp/.gitignore'

git :init
git :add => '.'
git :commit => "-m 'Initial commit of unmodified new Rails app'"

#----------------------------------------------------------------------------
# Remove unneeded files
#----------------------------------------------------------------------------
say("removing unneeded files...", :yellow)
run 'cp config/database.yml config/default.database.yml'
run 'rm public/index.html'
run 'rm public/favicon.ico'
run 'rm public/images/rails.png'
run 'rm README'
run 'touch README.mkd'

#----------------------------------------------------------------------------
# Setup database_name
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# Setup need gems
#----------------------------------------------------------------------------
say "setting up the Gemfile...", :yellow

gem 'by_star'
gem 'meta_where'
gem 'meta_search'
gem 'friendly_id'


gem 'inherited_resources_views'
gem 'inherited_resources'
gem 'has_scope'
gem 'responders'

gem 'compass'
gem "simple_form"
gem 'simple-navigation'
gem 'will_paginate'

gem 'rails_config'

gem 'unicorn'
gem 'thin'

gem 'capistrano'

gem 'awesome_print', :require => 'ap'
gem 'bullet', :group => 'development'

gem 'metrical', :group => 'development'

gem 'backup'

#----------------------------------------------------------------------------
# BDD Option
#----------------------------------------------------------------------------
if bdd_flag
  say("setting up Gemfile for BDD test...", :yellow)

  gem 'ZenTest', :group => ['development','test']
  gem 'rspec-rails', :group => ['development','test']
  gem 'cucumber-rails', :group => ['development','test']
  gem 'capybara', :group => ['development','test']
  gem 'factory_girl_rails', :group => ['development','test']
  gem 'database_cleaner', :group => ['development','test']
  gem "shoulda", :group => ['development','test']
  gem 'spork', :group => ['development','test']
  gem 'launchy', :group => ['development','test']

end

#----------------------------------------------------------------------------
# jQuery Option
#----------------------------------------------------------------------------
if jquery_flag
  say("setting up Gemfile for jQuery...", :yellow)
  gem 'jquery-rails'
end

#----------------------------------------------------------------------------
# Haml Option
#----------------------------------------------------------------------------
if haml_flag
  say("setting up Gemfile for haml...", :yellow)
  gem 'haml'
  gem "haml-rails"
  if devise_flag
    gem 'hpricot', :group => 'development'
    gem 'ruby_parser', :group => 'development'
  end
end

#----------------------------------------------------------------------------
# Devise Option
#----------------------------------------------------------------------------
if devise_flag
  say("setting up Gemfile for devise...", :yellow)
  gem 'devise'
end


# Install gems
say("installing gems (takes a few minutes!)...", :yellow)
run 'bundle install'

#----------------------------------------------------------------------------
# Set up installed Gems
#----------------------------------------------------------------------------
say "install friendly_id", :yellow
generate "friendly_id"
say "install inherited_resources_views", :yellow
generate "inherited_resources_views"
say "install navigation_config", :yellow
generate "navigation_config"
say "install rails_config", :yellow
generate "rails_config:install"
say "install responders", :yellow
generate "responders:install"
say "install simple_form", :yellow
generate "simple_form:install"
say "install compass", :yellow
run "compass create . --using blueprint"
say "install metrical", :yellow
run 'metrical'
say "install backup", :yellow
generate 'backup'
capify!

#----------------------------------------------------------------------------
# Set up BDD
#----------------------------------------------------------------------------
if bdd_flag
  say("replacing Test::Unit with BDD", :yellow)
  run 'rails generate rspec:install'
  say("install cucumber", :yellow)
  generate("cucumber:install")
end

#----------------------------------------------------------------------------
# Set up jQuery
#----------------------------------------------------------------------------
if jquery_flag
  run 'rm public/javascripts/rails.js'
  say("replacing Prototype with jQuery", :yellow)
  # "--ui" enables optional jQuery UI
  run 'rails generate jquery:install --ui'
end

#----------------------------------------------------------------------------
# Set up Devise
#----------------------------------------------------------------------------
if devise_flag
  run 'rails generate jquery:install --ui'
  generate("devise:install")
  generate("devise", model_name)
  generate("devise:views")
  #TODO 下面配置插入配置有bug
  #application(nil, :env => "development") do
  #  "config.action_mailer.default_url_options = { :host => 'localhost:3000' }"
  #end
end


application do
  "
    config.time_zone = 'Beijing'
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :'zh-CN'
    config.action_view.javascript_expansions[:defaults] = %w(jquery rails)
    config.after_initialize do
      config.active_record.default_timezone = :local
    end
  "
end

#FIXME bad smoke
run "sed -i -e '43d' config/application.rb"

rake 'db:migrate'


#----------------------------------------------------------------------------
# i18n
#----------------------------------------------------------------------------

get "https://github.com/svenfuchs/rails-i18n/raw/master/rails/locale/zh-CN.yml", "config/locales/zh-CN.yml"

get "https://gist.github.com/782413.txt", "config/locales/devise.zh-CN.yml"

get "https://gist.github.com/782437.txt", "config/locales/responders.zh-CN.yml"

get "https://gist.github.com/782456.txt", "config/locales/simple_form.zh-CN.yml"

get "https://gist.github.com/782459.txt", "config/locales/model.zh-CN.yml"


generate(:controller, "home index")
route "root :to => 'home#index'"

#----------------------------------------------------------------------------
# Finish up
#----------------------------------------------------------------------------
say("checking everything into git...", :yellow)
git :add => '.'
git :commit => "-a -m 'modified Rails app to start.'"

say("Done setting up your Rails app.", :yellow)
