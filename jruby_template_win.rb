require "thor/shell"
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

say "setting up the Gemfile...", :yellow

run 'rm .gitignore'
get "https://github.com/fsword/rails_templates/raw/master/resource/gitignore", ".gitignore"
run 'rm public/javascripts/rails.js'
run 'cp config/database.yml config/default.database.yml'
run 'rm public/index.html'
run 'rm public/favicon.ico'
run 'rm public/images/rails.png'
run 'rm README'

say("setting up Gemfile for BDD test...", :yellow)

#gem 'ZenTest', :group => ['development','test']
gem 'rspec-rails', :group => ['development','test']
gem 'cucumber-rails', :group => ['development','test']
gem 'capybara', :group => ['development','test']
gem 'factory_girl_rails', :group => ['development','test']
gem 'database_cleaner', :group => ['development','test']
gem "shoulda", :group => ['development','test']
gem 'spork', :group => ['development','test']
gem 'launchy', :group => ['development','test']

gem 'inherited_resources_views'
gem 'inherited_resources'

say("replacing Prototype with jQuery", :yellow)
say("setting up Gemfile for jQuery...", :yellow)
gem 'jquery-rails'

say("setting up Gemfile for devise...", :yellow)
gem 'devise'

gem 'jruby-openssl'
gem 'activerecord-jdbcsqlite3-adapter'

gsub_file 'config/database.yml', /adapter:\ sqlite3/, "adapter: jdbcsqlite3" 

gsub_file 'Gemfile', /gem\ 'sqlite3'/, "gem 'jdbc-sqlite3'" 

gsub_file 'config/application.rb', /(config.action_view.javascript_expansions.*)/,
        "config.action_view.javascript_expansions[:defaults] = %w(jquery rails)" 

# Install gems
say("installing gems (takes a few minutes!)...", :yellow)
run 'bundle install'

application do
  "
    require 'openssl'
    OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
    config.time_zone = 'Beijing'
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :'zh-CN'
    config.after_initialize do
      config.active_record.default_timezone = :local
    end
  "
end


get "https://github.com/svenfuchs/rails-i18n/raw/master/rails/locale/zh-CN.yml", "config/locales/zh-CN.yml"

url_pre="https://github.com/fsword/rails_templates/raw/master/resource/locale"
get "#{url_pre}/devise.zh-CN.yml", "config/locales/devise.zh-CN.yml"
get "#{url_pre}/responders.zh-CN.yml", "config/locales/responders.zh-CN.yml"
get "#{url_pre}/simple_form.zh-CN.yml", "config/locales/simple_form.zh-CN.yml"
get "#{url_pre}/model.zh-CN.yml", "config/locales/model.zh-CN.yml"

generate(:controller, "home index")
route "root :to => 'home#index'"


say("Done setting up your Rails app.", :yellow)

#jruby -S rails generate jquery:install --ui

#jruby -S rails generate devise:install
#jruby -S rails generate devise user
#jruby -S rails generate devise:views

## say("replacing Test::Unit with BDD", :yellow)
#jruby -S rails generate rspec:install
## say("install cucumber", :yellow)
#jruby -S rails generate cucumber:install

#say "install inherited_resources_views", :yellow
#jruby -S rails generate inherited_resources_views

#jruby -S rake db:migrate
